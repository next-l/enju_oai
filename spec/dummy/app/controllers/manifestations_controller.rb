# -*- encoding: utf-8 -*-
class ManifestationsController < ApplicationController
  load_and_authorize_resource :except => :index
  authorize_resource :only => :index
  include EnjuOai::OaiController if defined?(EnjuOai)
  include EnjuSearchLog if defined?(EnjuSearchLog)

  # GET /manifestations
  # GET /manifestations.json
  def index
    mode = params[:mode]
    if mode == 'add'
      unless current_user.try(:has_role?, 'Librarian')
        access_denied; return
      end
    end

    @seconds = Benchmark.realtime do
      if defined?(EnjuOai)
        @oai = check_oai_params(params)
        next if @oai[:need_not_to_search]
        if params[:format] == 'oai'
          oai_search = true
          from_and_until_times = set_from_and_until(Manifestation, params[:from], params[:until])
          from_time = @from_time = from_and_until_times[:from]
          until_time = @until_time = from_and_until_times[:until]
          # OAI-PMHのデフォルトの件数
          per_page = 200
          if params[:resumptionToken]
            current_token = get_resumption_token(params[:resumptionToken])
            if current_token
              page = (current_token[:cursor].to_i + per_page).div(per_page) + 1
            else
              @oai[:errors] << 'badResumptionToken'
            end
          end
          page ||= 1

          if params[:verb] == 'GetRecord' and params[:identifier]
            begin
              @manifestation = Manifestation.find_by_oai_identifier(params[:identifier])
            rescue ActiveRecord::RecordNotFound
              @oai[:errors] << "idDoesNotExist"
              render :formats => :oai, :layout => false
              return
            end
            render :template => 'manifestations/show', :formats => :oai, :layout => false
            return
          end
        end
      end

      set_reservable if defined?(EnjuCirculation)

      manifestations, sort, @count = {}, {}, {}
      query = ""

      if params[:format] == 'csv'
        per_page = 65534
      end

      if params[:format] == 'sru'
        if params[:operation] == 'searchRetrieve'
          sru = Sru.new(params)
          query = sru.cql.to_sunspot
          sort = sru.sort_by
        else
          render :template => 'manifestations/explain', :layout => false
          return
        end
      else
        if params[:api] == 'openurl'
          openurl = Openurl.new(params)
          @manifestations = openurl.search
          query = openurl.query_text
          sort = set_search_result_order(params[:sort_by], params[:order])
        else
          query = make_query(params[:query], params)
          sort = set_search_result_order(params[:sort_by], params[:order])
        end
      end

      # 絞り込みを行わない状態のクエリ
      @query = query.dup
      query = query.gsub('　', ' ')

      includes = [:carrier_type, :required_role, :items, :creators, :contributors, :publishers]
      includes << :bookmarks if defined?(EnjuBookmark)
      search = Manifestation.search(:include => includes)
      role = current_user.try(:role) || Role.default_role
      case @reservable
      when 'true'
        reservable = true
      when 'false'
        reservable = false
      else
        reservable = nil
      end

      patron = get_index_patron
      @index_patron = patron
      manifestation = @manifestation if @manifestation
      series_statement = @series_statement if @series_statement

      if defined?(EnjuSubject)
        subject = @subject if @subject
      end

      unless mode == 'add'
        search.build do
          with(:creator_ids).equal_to patron[:creator].id if patron[:creator]
          with(:contributor_ids).equal_to patron[:contributor].id if patron[:contributor]
          with(:publisher_ids).equal_to patron[:publisher].id if patron[:publisher]
          with(:original_manifestation_ids).equal_to manifestation.id if manifestation
          with(:series_statement_id).equal_to series_statement.id if series_statement
        end
      end

      search.build do
        fulltext query unless query.blank?
        order_by sort[:sort_by], sort[:order] unless oai_search
        order_by :updated_at, :desc if oai_search
        if defined?(EnjuSubject)
          with(:subject_ids).equal_to subject.id if subject
        end
        if series_statement
          with(:periodical_master).equal_to false
          if mode != 'add'
            with(:periodical).equal_to true
          end
        else
          if mode != 'add'
            with(:periodical).equal_to false
          end
        end
        facet :reservable if defined?(EnjuCirculation)
      end
      search = make_internal_query(search)
      search.data_accessor_for(Manifestation).select = [
        :id,
        :original_title,
        :title_transcription,
        :required_role_id,
        :carrier_type_id,
        :access_address,
        :volume_number_string,
        :issue_number_string,
        :serial_number_string,
        :date_of_publication,
        :pub_date,
        :language_id,
        :carrier_type_id,
        :created_at,
        :updated_at,
        :volume_number_string,
        :volume_number,
        :issue_number_string,
        :issue_number,
        :serial_number,
        :edition_string,
        :edition
      ] if params[:format] == 'html' or params[:format].nil?
      all_result = search.execute
      @count[:query_result] = all_result.total
      @reservable_facet = all_result.facet(:reservable).rows if defined?(EnjuCirculation)

      if session[:search_params]
        unless search.query.to_params == session[:search_params]
          clear_search_sessions
        end
      else
        clear_search_sessions
        session[:params] = params
        session[:search_params] == search.query.to_params
        session[:query] = @query
      end

      unless session[:manifestation_ids]
        manifestation_ids = search.build do
          paginate :page => 1, :per_page => configatron.max_number_of_results
        end.execute.raw_results.collect(&:primary_key).map{|id| id.to_i}
        session[:manifestation_ids] = manifestation_ids
      end

      if defined?(EnjuBookmark)
        if session[:manifestation_ids]
          if params[:view] == 'tag_cloud'
            bookmark_ids = Bookmark.where(:manifestation_id => session[:manifestation_ids]).limit(1000).select(:id).collect(&:id)
            @tags = Tag.bookmarked(bookmark_ids)
            render :partial => 'manifestations/tag_cloud'
            #session[:manifestation_ids] = nil
            return
          end
        end
      end

      page ||= params[:page] || 1
      per_page ||= Manifestation.per_page
      if params[:format] == 'sru'
        search.query.start_record(params[:startRecord] || 1, params[:maximumRecords] || 200)
      else
        search.build do
          facet :reservable if defined?(EnjuCirculation)
          facet :carrier_type
          facet :library
          facet :language
          facet :subject_ids if defined?(EnjuSubject)
          paginate :page => page.to_i, :per_page => per_page
        end
      end
      search_result = search.execute
      if @count[:query_result] > configatron.max_number_of_results
        max_count = configatron.max_number_of_results
      else
        max_count = @count[:query_result]
      end
      @manifestations = WillPaginate::Collection.create(page, per_page, max_count) do |pager|
        pager.replace(search_result.results)
      end

      if params[:format].blank? or params[:format] == 'html'
        @carrier_type_facet = search_result.facet(:carrier_type).rows
        @language_facet = search_result.facet(:language).rows
        @library_facet = search_result.facet(:library).rows
      end

      @search_engines = Rails.cache.fetch('search_engine_all'){SearchEngine.all}

      if defined?(EnjuBookmark)
        # TODO: 検索結果が少ない場合にも表示させる
        if manifestation_ids.blank?
          if query.respond_to?(:suggest_tags)
            @suggested_tag = query.suggest_tags.first
          end
        end
      end

      if defined?(EnjuSearchLog)
        save_search_history(query, @manifestations.offset, @count[:query_result], current_user)
      end

      if defined?(EnjuOai)
        if params[:format] == 'oai'
          unless @manifestations.empty?
            @resumption = set_resumption_token(
              params[:resumptionToken],
              @from_time || Manifestation.last.updated_at,
              @until_time || Manifestation.first.updated_at,
              @manifestations.per_page
            )
          else
            @oai[:errors] << 'noRecordsMatch'
          end
        end
      end
    end

    store_location # before_filter ではファセット検索のURLを記憶してしまう

    respond_to do |format|
      format.html
      format.mobile
      format.xml  { render :xml => @manifestations }
      format.sru  { render :layout => false }
      format.rss  { render :layout => false }
      format.csv  { render :layout => false }
      format.rdf  { render :layout => false }
      format.atom
      format.oai {
        case params[:verb]
        when 'Identify'
          render :template => 'manifestations/identify'
        when 'ListMetadataFormats'
          render :template => 'manifestations/list_metadata_formats'
        when 'ListSets'
          @series_statements = SeriesStatement.select([:id, :original_title])
          render :template => 'manifestations/list_sets'
        when 'ListIdentifiers'
          render :template => 'manifestations/list_identifiers'
        when 'ListRecords'
          render :template => 'manifestations/list_records'
        end
      }
      format.mods
      format.json { render :json => @manifestations }
      format.js
    end
  end

  private

  def make_query(query, options = {})
    # TODO: integerやstringもqfに含める
    query = query.to_s.strip

    if query.size == 1
      query = "#{query}*"
    end

    if options[:mode] == 'recent'
      query = "#{query} created_at_d:[NOW-1MONTH TO NOW]"
    end

    unless options[:tag].blank?
      query = "#{query} tag_sm:#{options[:tag]}"
    end

    unless options[:creator].blank?
      query = "#{query} creator_text:#{options[:creator]}"
    end

    unless options[:contributor].blank?
      query = "#{query} contributor_text:#{options[:contributor]}"
    end

    unless options[:isbn].blank?
      query = "#{query} isbn_sm:#{options[:isbn].gsub('-', '')}"
    end

    unless options[:issn].blank?
      query = "#{query} issn_s:#{options[:issn].gsub('-', '')}"
    end

    unless options[:lccn].blank?
      query = "#{query} lccn_s:#{options[:lccn]}"
    end

    unless options[:nbn].blank?
      query = "#{query} nbn_s:#{options[:nbn]}"
    end

    unless options[:publisher].blank?
      query = "#{query} publisher_text:#{options[:publisher]}"
    end

    unless options[:item_identifier].blank?
      query = "#{query} item_identifier_sm:#{options[:item_identifier]}"
    end

    unless options[:number_of_pages_at_least].blank? and options[:number_of_pages_at_most].blank?
      number_of_pages = {}
      number_of_pages[:at_least] = options[:number_of_pages_at_least].to_i
      number_of_pages[:at_most] = options[:number_of_pages_at_most].to_i
      number_of_pages[:at_least] = "*" if number_of_pages[:at_least] == 0
      number_of_pages[:at_most] = "*" if number_of_pages[:at_most] == 0

      query = "#{query} number_of_pages_i:[#{number_of_pages[:at_least]} TO #{number_of_pages[:at_most]}]"
    end

    query = set_pub_date(query, options)
    query = set_acquisition_date(query, options)

    query = query.strip
    if query == '[* TO *]'
      #  unless params[:advanced_search]
      query = ''
      #  end
    end

    return query
  end

  def set_search_result_order(sort_by, order)
    sort = {}
    # TODO: ページ数や大きさでの並べ替え
    case sort_by
    when 'title'
      sort[:sort_by] = 'sort_title'
      sort[:order] = 'asc'
    when 'pub_date'
      sort[:sort_by] = 'date_of_publication'
      sort[:order] = 'desc'
    else
      # デフォルトの並び方
      sort[:sort_by] = 'created_at'
      sort[:order] = 'desc'
    end
    if order == 'asc'
      sort[:order] = 'asc'
    elsif order == 'desc'
      sort[:order] = 'desc'
    end
    sort
  end

  def render_mode(mode)
    case mode
    when 'holding'
      render :partial => 'manifestations/show_holding', :locals => {:manifestation => @manifestation}
    when 'barcode'
      if defined?(EnjuBarcode)
        barcode = Barby::QrCode.new(@manifestation.id)
        send_data(barcode.to_svg, :disposition => 'inline', :type => 'image/svg+xml')
      end
    when 'tag_edit'
      if defined?(EnjuBookmark)
        render :partial => 'manifestations/tag_edit', :locals => {:manifestation => @manifestation}
      end
    when 'tag_list'
      if defined?(EnjuBookmark)
        render :partial => 'manifestations/tag_list', :locals => {:manifestation => @manifestation}
      end
    when 'show_index'
      render :partial => 'manifestations/show_index', :locals => {:manifestation => @manifestation}
    when 'show_creators'
      render :partial => 'manifestations/show_creators', :locals => {:manifestation => @manifestation}
    when 'show_all_creators'
      render :partial => 'manifestations/show_creators', :locals => {:manifestation => @manifestation}
    when 'pickup'
      render :partial => 'manifestations/pickup', :locals => {:manifestation => @manifestation}
    when 'calil_list'
      if defined?(EnjuCalil)
        render :partial => 'manifestations/calil_list', :locals => {:manifestation => @manifestation}
      end
    else
      false
    end
  end

  def prepare_options
    @carrier_types = CarrierType.all
    @content_types = ContentType.all
    @roles = Role.all
    @languages = Language.all_cache
    @frequencies = Frequency.all
    @nii_types = NiiType.all if defined?(NiiType)
  end

  def get_index_patron
    patron = {}
    case
    when params[:patron_id]
      patron[:patron] = Patron.find(params[:patron_id])
    when params[:creator_id]
      patron[:creator] = Patron.find(params[:creator_id])
    when params[:contributor_id]
      patron[:contributor] = Patron.find(params[:contributor_id])
    when params[:publisher_id]
      patron[:publisher] = Patron.find(params[:publisher_id])
    end
    patron
  end

  def set_reservable
    case params[:reservable].to_s
    when 'true'
      @reservable = true
    when 'false'
      @reservable = false
    else
      @reservable = nil
    end
  end

  def set_pub_date(query, options)
    unless options[:pub_date_from].blank? and options[:pub_date_to].blank?
      options[:pub_date_from].to_s.gsub!(/\D/, '')
      options[:pub_date_to].to_s.gsub!(/\D/, '')

      pub_date = {}
      if options[:pub_date_from].blank?
        pub_date[:from] = "*"
      else
        pub_date[:from] = Time.zone.parse(options[:pub_date_from]).beginning_of_day.utc.iso8601 rescue nil
        unless pub_date[:from]
          pub_date[:from] = Time.zone.parse(Time.mktime(options[:pub_date_from]).to_s).beginning_of_day.utc.iso8601
        end
      end

      if options[:pub_date_to].blank?
        pub_date[:to] = "*"
      else
        pub_date[:to] = Time.zone.parse(options[:pub_date_to]).end_of_day.utc.iso8601 rescue nil
        unless pub_date[:to]
          pub_date[:to] = Time.zone.parse(Time.mktime(options[:pub_date_to]).to_s).end_of_year.utc.iso8601
        end
      end
      query = "#{query} date_of_publication_d:[#{pub_date[:from]} TO #{pub_date[:to]}]"
    end
    query
  end

  def set_acquisition_date(query, options)
    unless options[:acquired_from].blank? and options[:acquired_to].blank?
      options[:acquired_from].to_s.gsub!(/\D/, '')
      options[:acquired_to].to_s.gsub!(/\D/, '')

      acquisition_date = {}
      if options[:acquired_from].blank?
        acquisition_date[:from] = "*"
      else
        acquisition_date[:from] = Time.zone.parse(options[:acquired_from]).beginning_of_day.utc.iso8601 rescue nil
        unless acquisition_date[:from]
          acquisition_date[:from] = Time.zone.parse(Time.mktime(options[:acquired_from]).to_s).beginning_of_day.utc.iso8601
        end
      end

      if options[:acquired_to].blank?
        acquisition_date[:to] = "*"
      else
        acquisition_date[:to] = Time.zone.parse(options[:acquired_to]).end_of_day.utc.iso8601 rescue nil
        unless acquisition_date[:to]
          acquisition_date[:to] = Time.zone.parse(Time.mktime(options[:acquired_to]).to_s).end_of_year.utc.iso8601
        end
      end
      query = "#{query} acquired_at_d:[#{acquisition_date[:from]} TO #{acquisition_date[:to]}]"
    end
    query
  end

  def set_title
    if @series_statement
      @manifestation.set_series_statement(@series_statement)
    elsif @original_manifestation
      @manifestation.original_title = @original_manifestation.original_title
      @manifestation.title_transcription = @original_manifestation.title_transcription
    end
  end
end
