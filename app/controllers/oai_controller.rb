class OaiController < ApplicationController
  def provider
    @oai = check_oai_params(params)
    @oai[:errors] = []
    if params[:verb] == 'GetRecord'
      if params[:identifier]
        begin
          @manifestation = Manifestation.find_by_oai_identifier(params[:identifier])
        rescue ActiveRecord::RecordNotFound
          @oai[:errors] << "idDoesNotExist"
          render formats: :xml, layout: false
          return
        end
        render template: 'oai/get_record', formats: :xml, layout: false
        return
      else
        @oai[:errors] << "idDoesNotExist"
        render formats: :xml, layout: false
        return
      end
    else
      from_and_until_times = set_from_and_until(Manifestation, params[:from], params[:until])
      from_time = @from_time = from_and_until_times[:from]
      until_time = @until_time = from_and_until_times[:until]

      # OAI-PMHのデフォルトの件数
      oai_per_page = 200
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

      @manifestations = Manifestation.search do
        order_by :updated_at, :desc
        paginate page: page, per_page: oai_per_page
      end.results

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
        case params[:verb]
        when 'Identify'
          render template: 'oai/identify'
        when 'ListMetadataFormats'
          render template: 'oai/list_metadata_formats'
        when 'ListSets'
          @series_statements = SeriesStatement.select([:id, :original_title])
          render template: 'oai/list_sets'
        when 'ListIdentifiers'
          render template: 'oai/list_identifiers'
        when 'ListRecords'
          render template: 'oai/list_records'
        else
          render template: 'oai/provider'
        end
      }
    end
  end
end
