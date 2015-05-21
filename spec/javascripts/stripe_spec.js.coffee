#= require spec_helper
#= require stripe

describe 'stripe PaymentProvider', ->
  describe '#tokenize', ->
    beforeEach ->
      @done = sinon.spy()
      @fail = sinon.spy()
      window.Stripe = { card: {} }
      @setPublishableKey = Stripe.setPublishableKey = sinon.stub()
      @createCardToken = sinon.stub()
      Stripe.card.createToken = @createCardToken
      @container = { data: sinon.stub() }
      @fields =
        name: 'Name De Card'
        card_number: '12345'
        expiration_month: '01'
        expiration_year: '2020'
        security_code: '123'

    it 'configures the stripe publishable key', ->
      @container.data.returns('the key')
      PaymentProvider.tokenize(@fields, 'card', @container)
      expect(@container.data.calledWithExactly('stripe-publishable-key')).to.be.ok
      expect(@setPublishableKey.calledWith('the key')).to.be.ok
      
    it 'translates the response on success', ->
      PaymentProvider.tokenize(@fields, 'card', @container).done(@done).fail(@fail)
      params =
        number: '12345'
        exp_month: '01'
        exp_year: '2020'
        cvc: '123'
      expect(@createCardToken.calledOnce).to.be.ok
      expect(@createCardToken.calledWith(params)).to.be.ok
      callback = @createCardToken.lastCall.args[1]
      response =
        id: 'tok_123'
        type: 'card'
        card:
          brand: 'Visa'
          last4: '0092'
          exp_month: '12'
          exp_year: '2021'
      callback(200, response)
      result =
        stripe_tok: 'tok_123'
        name: 'Name De Card'
        account_type: 'card'
        bank_name: 'Visa'
        last_four: '0092'
        expiration_month: '12'
        expiration_year: '2021'
      expect(@done.calledWith(result)).to.be.ok
      expect(@fail.called).to.not.be.ok

    it 'rejects the promise with errors if the response contains an error', ->
      PaymentProvider.tokenize(@fields, 'card', @container).done(@done).fail(@fail)
      expect(@createCardToken.calledOnce).to.be.ok
      callback = @createCardToken.lastCall.args[1]
      response =
        error:
          param: 'some_key'
          message: 'oops'
      # status code is ignored for now
      callback(200, response)
      result = [{
        param: 'some_key'
        message: 'oops'
      }]
      expect(@done.called).to.not.be.ok
      expect(@fail.calledWith(result)).to.be.ok

    it 'maps error param names back to app names', ->
      PaymentProvider.tokenize(@fields, 'card', @container).done(@done).fail(@fail)
      expect(@createCardToken.calledOnce).to.be.ok
      callback = @createCardToken.lastCall.args[1]
      response =
        error:
          param: 'number'
          message: 'dag yo'
      # status code is ignored for now
      callback(200, response)
      result = [{
        param: 'card_number'
        message: 'dag yo'
      }]
      expect(@done.called).to.not.be.ok
      expect(@fail.calledWith(result)).to.be.ok

