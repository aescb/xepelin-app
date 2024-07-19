module Public
  class ScrapperController < PublicController
    def create
      webhook_url = params[:webhook_url]
      category = params[:category]
      return head :bad_request unless BlogRequest.categories.include?(category)

      blog_request = BlogRequest.create(webhook_url: webhook_url, category: category)
      GetCategoryJob.perform_later(blog_request.id)
      return head :ok
    end
  end
end