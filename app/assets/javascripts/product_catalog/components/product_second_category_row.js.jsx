
(function() {
    var ProductSecondCategoryRow = React.createClass({
        propTypes: {
            category: React.PropTypes.string.isRequired
        },

        render: function() {
            return (
                <div className="product-catalog-second-category">{this.props.category}</div>
            );
        }
    });

    window.lo = window.lo || {};
    window.lo.ProductSecondCategoryRow = ProductSecondCategoryRow;
}).call(this);
