class ProductsController < ApplicationController
  before_action :find_product, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :edit]
  before_action :set_parents
  # before_action :set_product_purchase, only: [:purchase]
  
  def index
    @products = Product.includes(:images).order('created_at DESC')
    @product = Product.all.order("created_at DESC").limit(10)
    @brand = Product.where(brand: 'ロレックス').order("created_at DESC").limit(10)
  end

  def new
    @product = Product.new
    @images = @product.images.new
  end

  def category_children
    @category_children = Category.find(params[:parent_name]).children
  end

  def category_grandchildren
    @category_grandchildren = Category.find(params[:child_id]).children
  end  

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to @product
    else
      unless @product.images.present?
        @product.images.new
        render :new
      else
        render :new
      end
    end
  end
  
  def edit
    grandchild_category = @product.category
    child_category = grandchild_category.parent

    @category_parent_array = []
    @parents.each do |parent|
      @category_parent_array << parent.name
    end

    @category_children_array = []
    Category.where(ancestry: child_category.ancestry).each do |children|
      @category_children_array << children
    end

    @category_grandchildren_array = []
    Category.where(ancestry: grandchild_category.ancestry).each do |grandchildren|
      @category_grandchildren_array << grandchildren
    end
  end

  def update
    if @product.update(product_params)
      redirect_to product_path(@product), notice: '更新しました'
    else
      render 'edit'
    end
  end

  def show
    #ここのifはコントローラーに書かない方がいいかも。。。
    if user_signed_in? 
      @favorite = Favorite.find_by(user_id: current_user.id, product_id: @product.id)
    end

    @comment = Comment.new
    @comments = @product.comments.includes(:user)
    @condition = Condition.find(@product.condition_id)
    @shipping_cost = ShippingCost.find(@product.shipping_cost_id)
    @prefecture = Prefecture.find(@product.prefecture_id)
    @shipment_date = ShipmentDate.find(@product.shipment_date_id)
  end

  def destroy
    if @product.destroy
      redirect_to root_path, notice: '出品を削除しました'
    else
      redirect_to root_path, alert: "削除が失敗しました"
    end
  end

  def purchase
    @address = DeliveryAddress.where(user_id: current_user.id).first
    @product = Product.find(params[:id])
  end
# ------------------
  def done

  end
# -------------------
  private
  def product_params
    params.require(:product).permit(
      :name,
      :description,
      :price, 
      :brand,
      :condition_id, 
      :shipping_cost_id, 
      :shipment_date_id, 
      :prefecture_id, 
      :category_id, 
      [images_attributes: [:image, :_destroy, :id]]
      )
      .merge(seller_id: current_user.id)
  end

  def find_product
    @product = Product.includes(:images).find(params[:id])
  end
  
  # def set_product_purchase
  #   @product = Product.find(params[:id])
  # end
end
