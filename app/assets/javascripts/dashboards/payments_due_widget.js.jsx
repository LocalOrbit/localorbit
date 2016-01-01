(function() {
    window.lo = window.lo || {};

    var payments_due_widget = React.createClass({
        propTypes: {
            paymentsDueAmount: React.PropTypes.string
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
                            <div className="widget-value" id="paymentsDueAmount">
                                {this.props.paymentsDueAmount}
                            </div>
                            <div className="widget-label">
                                Payments Due
                            </div>
                        </div>
                    </div>
                    <div style={{borderTop: '1px solid #EEE', padding: 3}}>
                        <a href="/admin/financials"> <span style={{textTransform: 'uppercase', fontSize: 12, fontWeight: 'bold'}}>View More ></span></a>
                    </div>
                </div>
            );        }
    });

    window.lo.payments_due_widget = payments_due_widget;
    module.exports = payments_due_widget;

}).call(this);
