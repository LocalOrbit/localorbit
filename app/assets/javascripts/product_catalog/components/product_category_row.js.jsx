
(function() {
    var ProductCategoryRow = React.createClass({
        propTypes: {
            category: React.PropTypes.string.isRequired
        },

        render: function() {
            return (
                <div className="product-catalog-category">{this.props.category}</div>
            );
        }
    });

    window.lo = window.lo || {};
    window.lo.ProductCategoryRow = ProductCategoryRow;
}).call(this);
