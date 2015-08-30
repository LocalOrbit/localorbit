//= require underscore
//= require moment.min
//= require product_catalog/store

(function() {
  window.lo = window.lo || {};

  var ProductFilter = React.createClass({
    propTypes: {
      deliveryDate: React.PropTypes.string.isRequired
    },

    componentWillMount: function() {
      this.queryUpdated = _.debounce(this.queryUpdated, 300, false);
    },

    getInitialState: function() {
      return {
        deliveryDate: moment(this.props.deliveryDate),
        activeCategoryFilters: [],
        activeSellerFilters: [],
        query: ''
      };
    },

    activeFilters: function() {
      return this.state.activeSellerFilters.concat(this.state.activeSellerFilters);
    },

    queryUpdated: function() {
      window.lo.ProductActions.newQuery(this.state.query);
    },

    inputChanged: function(event) {
      var val = event.target.value;
      this.setState({query: val});
      this.queryUpdated();
    },

    render: function() {
      var filters = _.map(this.activeFilters(), function(filter) {
        return (<a href="javascript:void(0);" key={filter.name}>{filter.name}<i className="font-icon icon-close"></i></a>)
      });

      return (
        <div className="row catalog-search-container">
          <div className="catalog-search column column--half pull-left">
            <input className="" type="text" onChange={this.inputChanged} value={this.state.query} placeholder="Search..."/>
            <a href className="btn--secondary btn pull-right">Filter</a>
            <div className="filter-tags pull-left" style={{display: (filters.length === 0) ? "none" : ""}}>
              <span className="filter-tags-title">Filtering by: </span>
              {filters}
            </div>
          </div>
          <div className="order-information-container column column--half pull-left">
            Delivery date: <strong>{this.state.deliveryDate.format('dddd, MMM. D, YYYY')}</strong><br/>
            Time left to order: <strong>{this.state.deliveryDate.fromNow(true)}</strong><br/>
            <a href="/sessions/deliveries/new?redirect_back_to=%2Fproducts">Change delivery options</a>
          </div>
          <div style={{clear:"both"}}></div>
        </div>
      );
    }
  });

  window.lo.ProductFilter = ProductFilter;
}).call(this);
