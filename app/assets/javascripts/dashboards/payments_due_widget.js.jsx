(function() {
    window.lo = window.lo || {};

    var payments_due_widget = React.createClass({
        propTypes: {
            paymentsDueAmount: React.PropTypes.string.isRequired
        },

        render: function () {
            var self = this;

            return (
                <div className="dashboard-widget small-widget">
                    <div className="widget-value">
                        {this.props.paymentsDueAmount}
                    </div>
                    <div className="widget-label">
                        Payments Due
                    </div>
                    <div style={{borderTop: '1px solid #EEE', padding: 3}}>
                        <span style={{textTransform: 'uppercase', fontSize: 12, fontWeight: 'bold'}}>View More ></span>
                    </div>
                </div>
            );        }
    });

    window.lo.payments_due_widget = payments_due_widget;
    module.exports = payments_due_widget;

}).call(this);
