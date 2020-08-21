module Api::V1
  class ArticlesController < BaseApiController
    def index
      articles = Article.all.order(updated_at: "DESC")
      render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
    end

    def show
      article = Article.find(params[:id])
      render json: article, serializer: Api::V1::ArticleDetailSerializer
    end

    def create
      article = current_user.articles.build(article_params)

      article.save!

      render json: article
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
        params.require(:article).permit(:title, :body)
      end
  end
end
