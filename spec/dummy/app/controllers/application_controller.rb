class ApplicationController < ActionController::Base
  protect_from_forgery

  def clear_search_sessions
    session[:query] = nil
    session[:params] = nil
    session[:search_params] = nil
    session[:manifestation_ids] = nil
  end

  def set_role_query(user, search)
    role = user.try(:role) || Role.default_role
    search.build do
      with(:required_role_id).less_than_or_equal_to role.id
    end
  end

  def make_internal_query(search)
    # 内部的なクエリ
    set_role_query(current_user, search)

    unless params[:mode] == "add"
      expression = @expression
      patron = @patron
      manifestation = @manifestation
      reservable = @reservable
      carrier_type = params[:carrier_type]
      library = params[:library]
      language = params[:language]
      if defined?(EnjuSubject)
        subject = params[:subject]
        subject_by_term = Subject.where(:term => params[:subject]).first
        @subject_by_term = subject_by_term
      end

      search.build do
        with(:publisher_ids).equal_to patron.id if patron
        with(:original_manifestation_ids).equal_to manifestation.id if manifestation
        with(:reservable).equal_to reservable unless reservable.nil?
        unless carrier_type.blank?
          with(:carrier_type).equal_to carrier_type
        end
        unless library.blank?
          library_list = library.split.uniq
          library_list.each do |library|
            with(:library).equal_to library
          end
        end
        unless language.blank?
          language_list = language.split.uniq
          language_list.each do |language|
            with(:language).equal_to language
          end
        end
        if defined?(EnjuSubject)
          unless subject.blank?
            with(:subject).equal_to subject_by_term.term
          end
        end
      end
    end
    return search
  end

  def store_page
    if request.get? and request.format.try(:html?) and !request.xhr?
      flash[:page] = params[:page] if params[:page].to_i > 0
    end
  end

  def store_location
    if request.get? and request.format.try(:html?) and !request.xhr?
      session[:user_return_to] = request.fullpath
    end
  end
end
