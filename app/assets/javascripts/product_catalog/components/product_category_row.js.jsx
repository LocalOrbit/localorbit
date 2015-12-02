
(function() {
    var ProductCategoryRow = React.createClass({
        propTypes: {
            category: React.PropTypes.string.isRequired
        },

        render: function() {
            return (
                <div className="product-catalog-category product-category-divider">{this.props.category}</div>
            );
        }
    });

    window.lo = window.lo || {};
    window.lo.ProductCategoryRow = ProductCategoryRow;
}).call(this);
