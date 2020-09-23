class Merchant::DiscountsController < Merchant::BaseController
  def new
    @merchant = Merchant.find(params[:id])
  end

  def create
    @discount = Discount.create!(discount_params)
    redirect_to "/merchant/"
  end

  def edit
    @discount = Discount.find(params[:discount_id])
  end

  def update
    @discount = Discount.find(params[:id])
    @discount.update(discount_params)
    redirect_to "/merchant/"
  end

  def destroy
    Discount.find(params[:discount_id]).delete
    redirect_to "/merchant/"
  end

  private
  def discount_params
    params.permit(:percent_off, :min_quantity, :merchant_id)
  end

end
