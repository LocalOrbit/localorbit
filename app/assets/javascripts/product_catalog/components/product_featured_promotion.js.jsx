
(function() {
    var ProductFeaturedPromotion = React.createClass({
        propTypes: {
            hideImages: React.PropTypes.bool.isRequired,
            promo: React.PropTypes.object.isRequired
        },

        componentWillMount: function() {
            this.updateDimensions();
        },

        componentDidMount: function() {
            window.addEventListener('resize', this.updateDimensions);
        },

        componentWillUnmount: function() {
            window.removeEventListener('resize', this.updateDimensions);
        },

        updateDimensions: function() {
            this.setState({width: $(window).width()});
        },

        render: function() {
            var productRow;
            var gp = this.props.promo.product;
            var unit_prices = _.map(gp.available, function(p) {
                return <lo.ProductUnitPrices key={gp.id} product={p} />
            });

            var MOBILE_WIDTH = 480;
            var isMobile = this.state.width <= MOBILE_WIDTH;

            if (isMobile)
                productRow = (<lo.MobileProductRow key={gp.id} product={gp} hideImages={this.props.hideImages} promo={true}/>);
            else
                productRow = (<lo.ProductRow key={gp.id} product={gp} hideImages={this.props.hideImages} promo={true} />);

                return (
            <div className="products-featured">
                <h3 className="featured-heading">Featured: {this.props.promo.details.title}</h3>
                <div className="slide featured-table-slide" id="featured-table">
                    <div className="slide-content">
                        <div className="featured-description">
                            <div dangerouslySetInnerHTML={{__html: this.props.promo.details.body }}></div>
                        </div>
                        {productRow}
                    </div>
                </div>
            </div>
            );
        }
    });

    window.lo = window.lo || {};
    window.lo.ProductFeaturedPromotion = ProductFeaturedPromotion;
}).call(this);
