//= require underscore
//= require moment.min
//= require product_catalog/product_store
//= require product_catalog/filter_store

(function() {
  window.lo = window.lo || {};

  var ProductFilter = React.createClass({
    propTypes: {
      deliveryDate: React.PropTypes.string.isRequired,
      selectedType: React.PropTypes.string,
      orderCutoff: React.PropTypes.string.isRequired,
      buyerInfo: React.PropTypes.string.isRequired,
      supplierInfo: React.PropTypes.string,
      useTemplates: React.PropTypes.bool.isRequired,
      supplierOnly: React.PropTypes.bool,
      orderId: React.PropTypes.number,
      orderMinimum: React.PropTypes.string
    },

    getInitialState: function() {
      return {
        deliveryDate: moment(this.props.deliveryDate),
        orderCutoff: moment(this.props.orderCutoff),
        filters: {
          topLevel: [],
          children: []
        },
        activeFilters: [],
        selectedChild: {},
        showFilter: false,
        query: ''
      };
    },

    componentWillMount: function() {
      this.queryUpdated = _.debounce(this.queryUpdated, 750, false);
      window.lo.FilterStore.supplierOnly = this.props.supplierOnly;
      window.lo.FilterStore.listen(this.onFilterLoad);
      window.lo.FilterActions.loadInitialFilters();
    },

    onFilterLoad: function(filters) {
      this.setState({filters: filters});
    },

    toggleShowFilter: function() {
      this.setState({showFilter: !this.state.showFilter});
    },

    queryUpdated: function() {
      window.lo.ProductActions.newQuery(this.state.query);
    },

    inputChanged: function(event) {
      var val = event.target.value;
      this.setState({query: val});
      this.queryUpdated();
    },

    levelSelected: function(child) {
      this.setState({selectedChild: child});
      window.lo.FilterActions.loadChildFilters(child.id);
    },

    addFilter: function(filter, type) {
      filter.type = type;
      var filters = this.state.activeFilters.concat(filter);
      this.setState({activeFilters: filters});
      this.newFilters(filters);
    },

    removeFilter: function(index) {
      var filters = this.state.activeFilters;
      filters.splice(index, 1);
      this.setState({activeFilters: filters});
      this.newFilters(filters);
    },

    newFilters: function(filters) {
      var category_ids = _.pluck(_.where(filters, {type: "category"}), 'id');
      var seller_ids = _.pluck(_.where(filters, {type: "seller"}), 'id');
      window.lo.ProductActions.newFilters(category_ids, seller_ids);
    },

    render: function() {

      var activeFilters = _.map(this.state.activeFilters, function(filter, index) {
        return (
          <a href="javascript:void(0);" key={filter.id}>{filter.name}
            <i className="font-icon icon-close" onClick={this.removeFilter.bind(this, index)}></i>
          </a>
        )
      }.bind(this));

      var parentFilters = _.map(this.state.filters.topLevel, function(option) {
        return (
          <li key={option.id}>
            <a href="javascript:void(0);" onClick={this.levelSelected.bind(this, option)}>{option.name}</a>
          </li>
        )
      }.bind(this));

      var childFilters = _.map(this.state.filters.children, function(option) {
        var type = this.state.selectedChild.id === "suppliers" ? "seller" : "category";
        return (
          <li key={option.id}>
            <a href="javascript:void(0);" onClick={this.addFilter.bind(this, option, type)}>{option.name}</a>
          </li>
        )
      }.bind(this));

      var orderTemplates, filterText, orderMinimum, headerInformation, editDeliveryOptions;
      var buyerSeller, entityInfo;

        if(this.props.useTemplates)
            orderTemplates = (<a href="#templatePicker" className="app-apply-template modal-toggle">Apply an order template to the cart</a>);
        else
            orderTemplates = ('');

        if (!this.props.supplierOnly)
            filterText = (' and suppliers');
        else
            filterText = ('');

        if (this.props.orderMinimum)
            orderMinimum = (<span>Order Minimum: <strong>{this.props.orderMinimum}</strong><br/></span>);
        else
            orderMinimum = ('');

        editDeliveryOptions = (<span><a href="/sessions/organizations/new?redirect_back_to=%2Fsessions/deliveries/new?redirect_back_to=%2Fproducts">Change delivery options</a><br/></span>);
        buyerSeller = 'Buyer';
        entityInfo = this.props.buyerInfo;

        if (this.props.orderId > 0)
            headerInformation = ('');
        else
            headerInformation = (
                <div className="order-information-container column column--half pull-left">
                    {buyerSeller}: <strong>{entityInfo}</strong><br/>
                    {this.props.selectedType}: <strong>{this.state.deliveryDate.format('dddd, MMM. D, YYYY')}</strong><br/>
                    Time left to order: <strong>{this.state.orderCutoff.fromNow(true)}</strong><br/>
                    {orderMinimum}
                    {editDeliveryOptions}
                    {orderTemplates}
                </div>
            );

        return (
        <div style={{borderTop:"1px solid rgb(222, 222, 222)"}}>
          <div className="row catalog-search-container">
            <div className="catalog-search column column--half pull-left">
              <input className="app-search" name="app-search" type="text" onChange={this.inputChanged} value={this.state.query} placeholder="Search..."/>
              <a href="javascript:void(0);" onClick={this.toggleShowFilter} className="pull-right">{this.state.showFilter ? "Hide" : "Show"} Filter Options</a>
              <div className="filter-tags pull-left" style={{display: (activeFilters.length === 0) ? "none" : ""}}>
                <span className="filter-tags-title">Filtering by: </span>
                {activeFilters}
              </div>
            </div>
            {headerInformation}
            <div style={{clear:"both"}}></div>
          </div>
          <div style={{display: (this.state.showFilter) ? "" : "none"}} className="catalog-filter row">
            <div className="filter-level-1">
              <span>Filter the catalog by product categories {filterText}:</span>
              <ul>
                {parentFilters}
              </ul>
            </div>
            <div className="filter-level-2" style={{display: (this.state.selectedChild.id) ? "" : "none"}}>
                <span><i className="font-icon icon-close hidden"></i>{this.state.selectedChild.name}</span>
                <ul>
                  {childFilters}
                </ul>
              </div>
          </div>
        </div>
      );
    }
  });

  window.lo.ProductFilter = ProductFilter;
}).call(this);
