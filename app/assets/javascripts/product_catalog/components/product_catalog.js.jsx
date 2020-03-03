//= require underscore
//= require moment.min
//= require product_catalog/product_store

(function() {
  window.lo = window.lo || {};

  var ProductCatalog = React.createClass({
    propTypes: {
      cartUrl: React.PropTypes.string,
      baseUrl: React.PropTypes.string.isRequired,
      deliveryDate: React.PropTypes.string.isRequired,
      selectedType: React.PropTypes.string,
      orderCutoff: React.PropTypes.string.isRequired,
      buyerInfo: React.PropTypes.string.isRequired,
      supplierInfo: React.PropTypes.string,
      purchaseOrder: React.PropTypes.bool,
      salesOrder: React.PropTypes.bool,
      currentSupplier: React.PropTypes.number,
      useTemplates: React.PropTypes.bool.isRequired,
      supplierId: React.PropTypes.number,
      orderId: React.PropTypes.number,
      orderMinimum: React.PropTypes.string,
      supplierView: React.PropTypes.bool
    },

      componentWillMount: function() {
          window.lo.ProductStore.orderId = this.props.orderId;
      },

      render: function() {

        var orderTemplates;
        var productFilter;
        var productTable;
        var divClass;
        var divStyle;
        var closeButton;
        var stickFilters;

        if(this.props.useTemplates && !this.props.orderId)
            orderTemplates = (<lo.TemplatePicker baseUrl={this.props.baseUrl} cartUrl={this.props.cartUrl} />);
        else
            orderTemplates = ('');

        if (this.props.supplierId > 0 && this.props.supplierView) {
            window.lo.ProductActions.newFilters(null, this.props.supplierId);
            divClass = 'popup modal is-hidden app-supplier-catalog-modal';
            divStyle = ({maxHeight: '700px', background: 'white', overflow: 'scroll', top: '400'});
        }
        else {
            divClass = ('');
            divStyle = ({});
        }

        stickFilters = ('');

        if(this.props.currentSupplier > 0 && this.props.purchaseOrder) {
            window.lo.ProductActions.newFilters(null, this.props.currentSupplier);
        }

        if (this.props.orderId > 0)
            productFilter = ('');
        else
            productFilter = (<lo.ProductFilter
            deliveryDate={this.props.deliveryDate}
            selectedType={this.props.selectedType}
            orderCutoff={this.props.orderCutoff}
            buyerInfo={this.props.buyerInfo}
            supplierInfo={this.props.supplierInfo}
            purchaseOrder={this.props.purchaseOrder}
            useTemplates={this.props.useTemplates}
            supplierOnly={this.props.supplierId > 0}
            orderId={this.props.orderId}
            salesOrder={this.props.salesOrder}
            orderMinimum={this.props.orderMinimum}
            />);

        productTable = (<lo.ProductTable
            limit={30}
            filter={null}
            cartUrl={this.props.cartUrl}
            url={this.props.baseUrl + '/products'}
            supplierOnly={this.props.supplierId > 0}
            orderId={this.props.orderId}
            purchaseOrder={this.props.purchaseOrder}
            salesOrder={this.props.salesOrder}
            supplierView={this.props.supplierView}
        />);

        return (
        <div id='supplierCatalog' className={divClass} style={divStyle}>
          {orderTemplates}
          <div className={stickFilters}>
              {productFilter}
          </div>
          {productTable}
        </div>
        );
    }
  });

  window.lo.ProductCatalog = ProductCatalog;
}).call(this);
