require "spec_helper"

shared_examples "BillingPortal Session API" do
  let(:customer) { stripe_helper.create_customer({})}
  it "creates a billing portal session" do
    customer = 'cus_h32ihrui2f2'
    ret_url = 'https://app.example.com/account'
    bp = Stripe::BillingPortal::Session.create({customer: customer, return_url: ret_url})
    expect(bp.customer).to eq customer
    expect(bp.return_url).to eq ret_url
  end

  context "when creating a billing portal session" do
    it "requires customer and return_url params" do
      expect do
        Stripe::BillingPortal::Session.create(customer: 'cus_rfefe')
      end.to raise_error(Stripe::InvalidRequestError, /return_url/i)
      expect do
        Stripe::BillingPortal::Session.create(return_url: 'https://app.example.com')
      end.to raise_error(Stripe::InvalidRequestError, /customer/i)
    end
  end
end
