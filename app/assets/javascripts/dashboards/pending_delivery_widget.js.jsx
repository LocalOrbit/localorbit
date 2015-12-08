(function() {
    window.lo = window.lo || {};

    var pending_delivery = React.createClass({
        propTypes: {
            pendingDeliveryAmount: React.PropTypes.string.isRequired
        },

        render: function () {
            var self = this;

            return (
                <div className="dashboard-widget small-widget deliveries">
                    <div className="top-section">
                        <div style={{float: "left"}}>
                            <div className="widget-value deliveries">
                                {this.props.pendingDeliveryAmount}
                            </div>
                            <div className="widget-label deliveries">
                                Pending
                            </div>
                        </div>
                        <div style={{float: "right"}}>
                            <div className="font-icon deliveries icon-truck"></div>
                        </div>
                    </div>
                </div>
            );
        }
    });

    window.lo.pending_delivery = pending_delivery;
    module.exports = pending_delivery;

}).call(this);
