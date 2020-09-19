require 'rails_helper'

RSpec.describe 'Merchant items index page' do
  describe 'shows an existing discount' do
    it 'and that discount can be destroyed' do
      Discount.destroy_all
      megan = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      merchant = User.create(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan@example.com', password: 'securepassword', role: 1, merchant: megan)
      brian = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      ogre = megan.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      brian.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
      Discount.create!(discount: 0.2, quantity_required: 5, item_id: ogre.id, merchant_id: megan.id)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)


      visit "merchant/items"

      expect(page).to have_link("Remove Discount")
      expect(page).to have_link("Edit Bulk Discount")

      click_link "Remove Discount"

      expect(current_path).to eq("/merchant/items")
      expect(Discount.all).to eq([])
    end
  end
end
