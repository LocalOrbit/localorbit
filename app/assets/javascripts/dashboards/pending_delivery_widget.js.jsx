(function() {
    window.lo = window.lo || {};

    var pending_delivery = React.createClass({
        propTypes: {
            pendingDeliveryAmount: React.PropTypes.string
        },

        render: function () {
            var self = this;

            return (
                <div className="dashboard-widget small-widget deliveries">
                    <div className="top-section">
                        <div style={{float: "left"}}>
                            <div className="widget-value deliveries" id="pendingDeliveryAmount">
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
    window.require = require;

}).call(this);
