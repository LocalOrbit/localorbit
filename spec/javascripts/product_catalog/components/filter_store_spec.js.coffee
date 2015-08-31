#= require spec_helper
#= require product_catalog/filter_store

describe 'FilterStore', ->
  beforeEach ->
    @store = window.lo.FilterStore
    @actions = window.lo.FilterActions
    @ajaxSpy = sinon.stub($, 'getJSON')
    @triggerSpy = sinon.stub(@store, 'trigger')

  afterEach ->
    @ajaxSpy.restore()
    @triggerSpy.restore()

  describe '#init', ->
    it 'sets intial values', ->
      expect(@store.filters).to.eql {topLevel: [], children: []}
      expect(@store.cachedChildren).to.eql {}
      expect(@store.url).to.match /api\/v1\/filters$/

  describe '#loadChildFilters', ->
    it 'uses cached values whenever possible', ->
      @store.cachedChildren['foo'] = ['category1', 'category2']
      @store.loadChildFilters('foo')
      expect(@ajaxSpy.called).to.eq false

  describe '#onLoadChildFilters', ->
    it 'sets new child filters and triggers an update', ->
      childFilters = ['new filter1', 'new filter2']
      @store.onLoadChildFilters(childFilters)
      expect(@store.filters.children).to.eql childFilters
      expect(@triggerSpy.calledOnce).to.eq true

  describe '#onLoadInitialFilters', ->
    it 'sets the new topLevel filters, always with an initial suppliers entry', ->
      topLevelFilters = ['new filter1', 'new filter2']
      @store.onLoadInitialFilters({filters: topLevelFilters})
      expect(@store.filters.topLevel).to.eql [{name: 'Suppliers', id: 'suppliers'}].concat topLevelFilters
      expect(@triggerSpy.calledOnce).to.eq true
