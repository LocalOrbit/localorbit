
(function() {
    var ProductFeaturedPromotion = React.createClass({
        propTypes: {
            hideImages: React.PropTypes.bool.isRequired,
            promo: React.PropTypes.object.isRequired
        },

        render: function() {

            var gp = this.props.promo.product;
            var unit_prices = _.map(gp.available, function(p) {
                return <lo.ProductUnitPrices product={p} />
            });

            return (
            <div className="product-promotion">
                <h3 className="featured-heading">Featured: {this.props.promo.details.title}</h3>
                <div className="featured-description">
                    <div dangerouslySetInnerHTML={{__html: this.props.promo.details.body }} />
                </div><br/>
                <lo.ProductRow key={gp.id} product={gp} hideImages={this.props.hideImages}/>
            </div>
            );
        }
    });

    window.lo = window.lo || {};
    window.lo.ProductFeaturedPromotion = ProductFeaturedPromotion;
}).call(this);
