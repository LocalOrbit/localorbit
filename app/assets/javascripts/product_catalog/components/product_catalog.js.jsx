//= require underscore
//= require moment.min
//= require product_catalog/product_store

(function() {
  window.lo = window.lo || {};

  var ProductCatalog = React.createClass({
    propTypes: {
      cartUrl: React.PropTypes.string.isRequired,
      baseUrl: React.PropTypes.string.isRequired,
      deliveryDate: React.PropTypes.string.isRequired,
      selectedType: React.PropTypes.string.isRequired,
      orderCutoff: React.PropTypes.string.isRequired,
      buyerInfo: React.PropTypes.string.isRequired,
      useTemplates: React.PropTypes.bool.isRequired
    },

      render: function() {

        var orderTemplates;
        if(this.props.useTemplates)
            orderTemplates = (<lo.TemplatePicker baseUrl={this.props.baseUrl} cartUrl={this.props.cartUrl} />);
        else
            orderTemplates = ('');

        return (
        <div>
          {orderTemplates}
          <lo.ProductFilter
            deliveryDate={this.props.deliveryDate}
            selectedType={this.props.selectedType}
            orderCutoff={this.props.orderCutoff}
            buyerInfo={this.props.buyerInfo}
            useTemplates={this.props.useTemplates}
          />
          <lo.ProductTable
            limit={30}
            filter={null}
            cartUrl={this.props.cartUrl}
            url={this.props.baseUrl + '/products'}
          />
        </div>
      );
    }
  });

  window.lo.ProductCatalog = ProductCatalog;
}).call(this);
