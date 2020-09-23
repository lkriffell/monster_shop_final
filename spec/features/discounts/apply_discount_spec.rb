require 'rails_helper'

RSpec.describe 'On checkout' do
  describe 'Any item elligable for discount' do
    before :each do
      megan = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      user = User.create(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'someone@example.com', password: 'securepassword')
      brian = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @ogre = megan.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @hippo = brian.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 20 )
      @giant = brian.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 20 )
      discount = Discount.create!(percent_off: 0.1, min_quantity: 5, merchant_id: megan.id)
      discount = Discount.create!(percent_off: 0.5, min_quantity: 5, merchant_id: brian.id)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    end
    it 'has no discount applied' do

      visit "/items/#{@ogre.id}"

      click_button "Add to Cart"

      click_link "Cart: 1"

      3.times do
        click_button "More of This!"
      end

      expect(page).to have_content("Total: $80.00")
      expect(page).to have_content("Total (After Discount): $80.00")
    end

    it 'has discount applied' do

      visit "/items/#{@ogre.id}"

      click_button "Add to Cart"

      click_link "Cart: 1"

      4.times do
        click_button "More of This!"
      end

      expect(page).to have_content("Total: $100.00")
      expect(page).to have_content("Total (After Discount): $90.00")
    end

    it 'has multiple discounts applied' do

      visit "/items/#{@ogre.id}"

      click_button "Add to Cart"

      click_link "Cart: 1"

      4.times do
        click_button "More of This!"
      end

      expect(page).to have_content("Total: $100.00")
      expect(page).to have_content("Total (After Discount): $90.00")

      visit "/items/#{@hippo.id}"

      click_button "Add to Cart"

      click_link "Cart: 6"

      4.times do
        click_button "More of This!"
      end

      expect(page).to have_content("Total: $350.00")
      expect(page).to have_content("Total (After Discount): $215.00")
    end

    it 'has largest discount applied except for item inelligable for discount' do

      visit "/items/#{@ogre.id}"
      click_button "Add to Cart"

      visit "/items/#{@giant.id}"

      click_button "Add to Cart"

      click_link "Cart:"

      4.times do
        within "#item-#{@giant.id}" do
          click_button "More of This!"
        end
      end

      expect(page).to have_content("Total: $270.00")
      expect(page).to have_content("Total (After Discount): $145.00")

      visit "/items/#{@hippo.id}"

      click_button "Add to Cart"

      click_link "Cart:"

      4.times do
        within "#item-#{@hippo.id}" do
          click_button "More of This!"
        end
      end

      expect(page).to have_content("Total: $520.00")
      expect(page).to have_content("Total (After Discount): $270.00")
    end
  end
end
