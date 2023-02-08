class ProductsController < ApplicationController
  before_action :set_products
  before_action :ensure_category, except: [:index, :show, :custom_field_ids]
  before_action :ensure_manufacturer, only: [:get_models_by_manufacturer, :variations, :sizes]
  before_action :ensure_model, only: [:variations, :sizes]
  serialization_scope :category_specific
  
  def index 
    render json: @products
  end

  def show 
    render json: @product.options
  end

  # get '/products/categories/:category'
  def category_hash 
    category = Category.find_by_url_or_id(params[:category])
    render json: Product.category_hash(params[:category])
  end

  # get '/products/categories/:category_id/custom_field_ids'
  def custom_field_ids 
    render json: Product.custom_field_ids(params[:category_id])
  end

  # get 'categories/:category/manufacturers', helper: :category_manufacturers
  def get_manufacturers 
    render json: Product.products_by_category(params[:category])
  end
 
  # get 'categories/:category/models', helper: :category_models
  def get_models
    render json: Product.models_by_category(params[:category])
  end

  # get 'categories/:category/manufacturers/:manufacturer_name/models', helper: :category_manufacturer_models
  def get_models_by_manufacturer
    render json: Product.models_by_manufacturer_and_category(params[:category], params[:manufacturer_name])
  end

  # get 'categories/:category/manufacturers/:manufacturer_name/models/:model_name', helper: :category_manufacturer_model_variations
  def variations
    render json: Product.category_manufacturer_model_variations(params[:category], params[:manufacturer_name], params[:model_name])
  end

  # get 'categories/:category/manufacturers/:manufacturer_name/models/:model_name/sizes', helper: :category_manufacturer_model_sizes
  def sizes 
    render json: Product.category_manufacturer_model_sizes(params[:category], params[:manufacturer_name], params[:model_name])
  end

  private 

  def ensure_category
    redirect_to products_path unless params[:category]
  end

  def ensure_manufacturer 
    redirect_to products_path unless params[:manufacturer_name]
  end

  def ensure_model 
    redirect_to products_path unless params[:model_name]
  end

  def set_products 
    category = Category.find_by(id: params[:category_id])
    if category 
      if category.has_subcategories? 
        @products = Product.where(category_id: category.subcategory_ids)
      else 
        @products = category.products
      end
    else 
      @products = Product.all
    end
  end

  def category_specific 
    !!params[:category_id]
  end
end
