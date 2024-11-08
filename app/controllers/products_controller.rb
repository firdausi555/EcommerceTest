class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]
  
  # GET /products or /products.json
  def index
    search_query = params[:query]
    if current_user&.role == "seller"
      # Seller-specific logic
      if search_query.present? && params[:category].present?
        @products = current_user.products.search(search_query, page: params[:page], per_page: 6)
                                      .where(category: params[:category])
      elsif search_query.present?
        @products = current_user.products.search(search_query, page: params[:page], per_page: 6)
      elsif params[:category].present?
        @products = current_user.products.where(category: params[:category])
                                         .page(params[:page]).per(6)
      else
        @products = current_user.products.page(params[:page]).per(6)
      end
    else
      # Default behavior for other users (or non-sellers)
      if search_query.present? && params[:category].present?
        @products = Product.search(search_query, page: params[:page], per_page: 6)
                           .where(category: params[:category])
      elsif search_query.present?
        @products = Product.search(search_query, page: params[:page], per_page: 6)
      elsif params[:category].present?
        @products = Product.where(category: params[:category])
                           .page(params[:page]).per(6)
      else
        @products = Product.page(params[:page]).per(6)
      end
    end
    
  end

  # GET /products/1 or /products/1.json
  def show
    @product
  end

  # GET /products/new
  def new
    @product = Product.new
    @categories=Category.all
  end

  # GET /products/1/edit
  def edit
    @categories=Category.all
  end

  # POST /products or /products.json
  def create
    @categories=Category.all

    if current_user&.role=="seller"
      @product = current_user.products.new(product_params)

      respond_to do |format|
        if @product.save
          format.html { redirect_to @product, notice: "Product was successfully created." }
          format.json { render :show, status: :created, location: @product }
        else
          @categories=Category.all

          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @product.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_path, status: :see_other, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.require(:product).permit(:title, :description, :image_url, :price,:quantity, :category_id)
    end 
end
