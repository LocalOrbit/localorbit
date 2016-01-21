(function() {
    window.lo = window.lo || {};

    var payments_overdue_widget = React.createClass({
        propTypes: {
            paymentsOverdueAmount: React.PropTypes.string
        },

        render: function () {
            var self = this;

            return (
                <div className="dashboard-widget small-widget">
                    <div className="top-section">
                        <div style={{float: "left"}}>
                            <div className="font-icon icon-stack-list"></div>
                        </div>
                        <div style={{float: "right", paddingRight:10}}>
                            <div className="widget-value" id="paymentsOverdueAmount">
                                {this.props.paymentsOverdueAmount}
                            </div>
                            <div className="widget-label">
                                Overdue
                            </div>
                        </div>
                    </div>
                    <div style={{borderTop: '1px solid #EEE', padding: 3}}>
                        <a href="/admin/financials"><span style={{textTransform: 'uppercase', fontSize: 12, fontWeight: 'bold'}}>View Details ></span></a>
                    </div>
                </div>
            );        }
    });

    window.lo.payments_overdue_widget = payments_overdue_widget;
    window.require = require;

}).call(this);
