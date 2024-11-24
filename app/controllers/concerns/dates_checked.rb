module DatesChecked
  extend ActiveSupport::Concern

  included do
    private
    def dates_valid?
      @dates_error_message = if params[:start_date].present? != params[:end_date].present?
                               'Необходимо указать обе даты'
                             elsif params[:start_date] > params[:end_date]
                               'Неверно указаны даты'
                             end

      @dates_error_message.nil?
    end

    def dates_error_message
      @dates_error_message
    end

    def respond_date_error
      request.format = :html if request.format.xlsx?

      respond_to do |format|
        format.html do
          flash.now[:alert] = dates_error_message
          @posts = Post.none
          render :index
        end
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('forms_errors',
                                render_to_string(partial: 'shared/error_messages',
                                                 locals: { message: dates_error_message })),
            turbo_stream.update('posts',
                                render_to_string(partial: 'posts/post_index',
                                                 collection: Post.none,
                                                 as: :post))
          ]
        end
      end
    end
  end
end
