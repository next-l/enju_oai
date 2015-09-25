class OaiController < ApplicationController
  def provider
    @oai = check_oai_params(params)
    if params[:verb] == 'GetRecord'
      get_record; return
    else
      from_and_until_times = set_from_and_until(Manifestation, params[:from], params[:until])
      from_time = @from_time = from_and_until_times[:from]
      until_time = @until_time = from_and_until_times[:until]

      # OAI-PMHのデフォルトの件数
      oai_per_page = 200
      search = Manifestation.search do
        order_by :updated_at, :desc
        paginate page: 1, per_page: oai_per_page
      end
      @count = {query_result: search.execute!.total}

      if params[:resumptionToken]
        token = params[:resumptionToken].split(',')
        if token.size == 3
          @cursor = token.reverse.first.to_i
          if @cursor <= @count[:query_result]
            page = (@cursor.to_i + oai_per_page).div(oai_per_page)
          else
            @oai[:errors] << 'badResumptionToken'
          end
        else
          @oai[:errors] << 'badResumptionToken'
        end
      end
      page ||= 1

      search.build do
        order_by :updated_at, :desc
        paginate page: page, per_page: oai_per_page
      end
      @manifestations = search.execute!.results

      unless @manifestations.empty?
        @resumption = set_resumption_token(
          params[:resumptionToken],
          @from_time || Manifestation.order(:updated_at).first.updated_at,
          @until_time || Manifestation.order(:updated_at).last.updated_at
        )
      else
        @oai[:errors] << 'noRecordsMatch'
      end
    end

    respond_to do |format|
      format.xml {
        if @oai[:errors].empty?
          case params[:verb]
          when 'Identify'
            render template: 'oai/identify', content_type: 'text/xml'
          when 'ListMetadataFormats'
            render template: 'oai/list_metadata_formats', content_type: 'text/xml'
          when 'ListSets'
            @series_statements = SeriesStatement.select([:id, :original_title])
            render template: 'oai/list_sets', content_type: 'text/xml'
          when 'ListIdentifiers'
            render template: 'oai/list_identifiers', content_type: 'text/xml'
          when 'ListRecords'
            render template: 'oai/list_records', content_type: 'text/xml'
          else
            render template: 'oai/provider', content_type: 'text/xml'
          end
        else
          render template: 'oai/provider', content_type: 'text/xml'
        end
      }
    end
  end

  private
  def get_record
    if params[:identifier]
      begin
        @manifestation = Manifestation.find_by_oai_identifier(params[:identifier])
      rescue ActiveRecord::RecordNotFound
        @oai[:errors] << "idDoesNotExist"
        render template: 'oai/provider', content_type: 'text/xml'
      end
      render template: 'oai/get_record', content_type: 'text/xml'
      return
    else
      @oai[:errors] << "idDoesNotExist"
      render template: 'oai/provider', content_type: 'text/xml'
    end
  end
end
