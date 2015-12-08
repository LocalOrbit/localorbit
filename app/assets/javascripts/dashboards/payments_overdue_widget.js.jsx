(function() {
    window.lo = window.lo || {};

    var payments_overdue_widget = React.createClass({
        propTypes: {
            paymentsOverDueAmount: React.PropTypes.string.isRequired
        },

        render: function () {
            var self = this;

            return (
                <div className="dashboard-widget small-widget">
                    <div className="top-section">
                        <div style={{float: "left"}}>
                            <div className="font-icon icon-stack-list"></div>
                        </div>
                        <div style={{float: "right"}}>
                            <div className="widget-value">
                                {this.props.paymentsOverDueAmount}
                            </div>
                            <div className="widget-label">
                                Overdue
                            </div>
                        </div>
                    </div>
                    <div style={{borderTop: '1px solid #EEE', padding: 3}}>
                        <span style={{textTransform: 'uppercase', fontSize: 12, fontWeight: 'bold'}}>View More ></span>
                    </div>
                </div>
            );        }
    });

    window.lo.payments_overdue_widget = payments_overdue_widget;
    module.exports = payments_overdue_widget;

}).call(this);
