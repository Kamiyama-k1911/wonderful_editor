module Api::V1
  class ArticlesController < BaseApiController
    before_action :authenticate_user!, except: [:index, :show]
    def index
      @articles = Article.published.order(updated_at: "DESC")
      render json: @articles, each_serializer: Api::V1::ArticlePreviewSerializer
    end

    def show
      @article = Article.published.find(params[:id])

      render json: @article, serializer: Api::V1::ArticleDetailSerializer
    end

    def create
      @article = current_user.articles.build(article_params)
      @article.save!
      render json: @article
    end

    def update
      article = current_user.articles.find(params[:id])

      article.update!(article_params)

      render json: article
    end

    def destroy
      article = current_user.articles.find(params[:id])

      article.destroy!
    end

    private

      def article_params
        params.require(:article).permit(:title, :body, :status)
      end
  end
end
