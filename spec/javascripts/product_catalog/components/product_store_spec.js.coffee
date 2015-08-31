#= require spec_helper
#= require product_catalog/product_store

describe 'ProductStore', ->
  beforeEach ->
    @store = window.lo.ProductStore
    @actions = window.lo.ProductActions
    @ajaxSpy = sinon.stub($, 'getJSON')
    @triggerSpy = sinon.stub(@store, 'trigger')

  afterEach ->
    @ajaxSpy.restore()
    @triggerSpy.restore()

  it 'exists', ->
    expect(@store).to.not.eq null

  describe 'init', ->
    it 'sets default variables', ->
      expect(@store.catalog.products).to.be.empty
      expect(@store.catalog.hasMore).to.eq true
      expect(@store.url).to.match /api\/v1\/products$/
      expect(@store.parameters.offset).to.eq 0
      expect(@store.parameters.category_ids).to.be.empty
      expect(@store.parameters.seller_ids).to.be.empty

  describe '#loadProducts ', ->
    it 'sets loading to true and offset to 0', ->
      @store.loadProducts()
      expect(@store.parameters.offset).to.eq 0
      expect(@store.loading).to.eq true
      expect(@ajaxSpy.called).to.eq true

  describe '#onLoad', ->
    it 'sets the catalog and whether or not there are more results to fetch', ->
      @store.catalog.products = ['foo', 'bar']
      @store.onLoad({products: ['baz'], product_total: 2})
      expect(@triggerSpy.called).to.eq true
      expect(@store.catalog.products).to.eql ['baz']
      expect(@store.catalog.hasMore).to.eq true
      @store.onLoad({products: ['baz'], product_total: 1})
      expect(@store.catalog.hasMore).to.eq false

  describe '#loadMoreProducts ', ->
    it 'does nothing if products are already being loaded', ->
      expect(@ajaxSpy.called).to.eq false
      @store.loading = true
      @store.loadMoreProducts()
      expect(@ajaxSpy.called).to.eq false
      @store.loading = false
      @store.catalog.hasMore = false
      @store.loadMoreProducts()
      expect(@ajaxSpy.called).to.eq false
      @store.loading = false
      @store.catalog.hasMore = true
      @store.loadMoreProducts()
      expect(@ajaxSpy.called).to.eq true

  describe '#onLoadMore', ->
    it 'sets the catalog and whether or not there are more results to fetch', ->
      @store.catalog.products = ['foo', 'bar']
      @store.onLoadMore({products: ['baz'], product_total: 4})
      expect(@triggerSpy.called).to.eq true
      expect(@store.catalog.products).to.eql ['foo', 'bar', 'baz']
      expect(@store.catalog.hasMore).to.eq true
      @store.onLoadMore({products: ['foo', 'bar', 'baz'], product_total: 3})
      expect(@store.catalog.hasMore).to.eq false

  describe '#newFilters', ->
    it 'sets the new filters and triggers a catalog reload', ->
      loadSpy = sinon.stub(@store, 'loadProducts')
      expect(@store.parameters.category_ids).to.eql []
      expect(@store.parameters.seller_ids).to.eql []
      @store.newFilters(['foo', 'bar'], ['baz'])
      expect(@store.parameters.category_ids).to.eql ['foo', 'bar']
      expect(@store.parameters.seller_ids).to.eql ['baz']
      expect(loadSpy.called).to.eq true
