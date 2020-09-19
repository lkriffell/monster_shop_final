class Merchant::DiscountsController < Merchant::BaseController
  def new
    @item = Item.find(params[:id])
    @merchant = Merchant.find(@item.merchant_id)
  end

  def create
    @discount = Discount.create!(discount_params)
    redirect_to "/merchant/items"
  end

  def edit
    @item = Item.find(params[:id])
    @discount = @item.discount
  end

  def update
    @discount = Discount.find(params[:id])
    @discount.update(discount_params)
    redirect_to "/merchant/items"
  end

  def destroy
    @item = Item.find(params[:id])
    @item.discount.delete
    redirect_to "/merchant/items"
  end

  private
  def discount_params
    params.permit(:discount, :quantity_required, :item_id, :merchant_id)
  end

end
