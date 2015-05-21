#= require spec_helper
#= require tokenizer

describe "PaymentSourceErrors", ->

  beforeEach ->
    $('body').append('<ul id="payment-provider-errors" />')

  describe "#displayError", ->
    it "adds a filed-based error to the error container", ->
      PaymentSourceErrors.displayError "foo", "bar"
      expect($('#payment-provider-errors li')).to.have.html('foo: bar')

  describe "#displayGenericError", ->
    it "adds an error to the error container", ->
      PaymentSourceErrors.displayGenericError "foo, yall"
      expect($('#payment-provider-errors li')).to.have.html('foo, yall')

  describe "#setupErrorsContainer", ->
    it "clears the container if present", ->
      $('#payment-provider-errors').html('hello')
      PaymentSourceErrors.setupErrorsContainer $('body')
      expect($('#payment-provider-errors').html()).to.be.empty

    it "prepends the container if not present", ->
      $('body').html('')
      PaymentSourceErrors.setupErrorsContainer $('body')
      expect($('#payment-provider-errors.form-errors')).to.exist

describe "PaymentSourceTokenizer", ->

  describe "#tokenize", ->
    before ->
      window.PaymentProvider = {}

    after ->
      window.PaymentProvider = undefined

    beforeEach ->
      @deferred = $.Deferred()
      @promise = @deferred.promise()
      @tokenize_stub = PaymentProvider.tokenize = sinon.stub().returns(@promise)
      @$form = $('<form />')
      @tokenizer = new PaymentSourceTokenizer @$form, 'the container', (key) -> "x-#{key}"
      @done = sinon.spy()
      @fail = sinon.spy()


    describe "successful tokenization", ->
      it "adds the resulting fields to the form", ->
        @tokenizer.tokenize('the data', 'a type').done(@done).fail(@fail)
        @deferred.resolve(
          foo: 'bar',
          baz: 'qux'
        )
        expect(@$form.children().length).to.equal(2)
        expect(@$form.find("input[name=x-foo]").val()).to.equal('bar')
        expect(@$form.find("input[name=x-baz]").val()).to.equal('qux')

      it "resolve the promise w/the addField function", ->
        @tokenizer.tokenize('the data', 'a type').done(@done).fail(@fail)
        @deferred.resolve({})
        expect(@done.called).to.be.ok
        expect(@fail.called).to.not.be.ok

      it "submits the form", ->
        submitSpy = sinon.spy(@$form, 'submit')
        @tokenizer.tokenize('the data', 'a type').done(@done).fail(@fail)
        @deferred.resolve({})
        expect(submitSpy.calledOnce).to.be.ok

    describe "failed tokenization", ->
      beforeEach ->
        @displayErrorsSpy = sinon.stub(PaymentSourceErrors, 'displayErrors')
      afterEach ->
        @displayErrorsSpy.restore()

      it "displays errors", ->
        @tokenizer.tokenize('the data', 'a type').done(@done).fail(@fail)
        @deferred.reject('the errors')
        expect(@displayErrorsSpy.calledWithExactly('the container', 'the errors')).to.be.ok

      it "rejects the promise", ->
        @tokenizer.tokenize('the data', 'a type').done(@done).fail(@fail)
        @deferred.reject('the errors')
        expect(@done.called).to.not.be.ok
        expect(@fail.called).to.be.ok


