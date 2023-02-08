class Api::V1::CategoriesController < Api::V1::BaseController
  swagger_controller :categories, 'Categories'

  swagger_api :index do
    summary "Fetches all categories"
    notes "This lists all the open categories"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  swagger_api :show do
    summary "Fetches a single category and their custom fields"
    param :path, :id, :integer, :required, "Category Id"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  swagger_api :sub_categories do
    summary "Fetches sub-categories of a category"
    param :path, :id, :integer, :required, "Category Id"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  def index
    categories = current_community.categories.includes(:children)
    main_categories = categories.select { |c| c.parent_id == nil }
    if categories.present?
      render json: main_categories, each_serializer: AllCategorySerializer, status: 200
    else
      render json: {error: "Categories not found." }, status: 400
    end
  end

  def sub_categories
    category = Category.find_by(id: params[:id])
    if category.children.present?
      render json: category.children, each_serializer: AllCategorySerializer, status: 200
    else
      render json: {error: "This category doesn't have any sub category." }, status: 400
    end
  end

  def show
    category = Category.find_by(id: params[:id])
    if category.present?
      render json: category, status: 200
    else
      render json: {error: "Category not found." }, status: 400
    end
  end
end
