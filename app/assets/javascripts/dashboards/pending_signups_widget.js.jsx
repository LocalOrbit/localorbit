(function() {
    window.lo = window.lo || {};

    var pending_signups_widget = React.createClass({
        propTypes: {
            numPendingBuyers: React.PropTypes.string
        },

        render: function () {
            var self = this;

            return (
                <div className="dashboard-widget small-widget">
                    <div className="top-section">
                        <div style={{float: "left"}}>
                            <div className="font-icon icon-picture"></div>
                        </div>
                        <div style={{float: "right", paddingRight:10}}>
                            <div className="widget-value" id="numPendingBuyers">
                                {this.props.numPendingBuyers}
                            </div>
                            <div className="widget-label">
                                Pending Buyers
                            </div>
                        </div>
                    </div>
                    <div style={{borderTop: '1px solid #EEE', padding: 3}}>
                        <a href="/admin/organizations"><span style={{textTransform: 'uppercase', fontSize: 12, fontWeight: 'bold'}}>View Details ></span></a>
                        <span className="tooltip pull-right" data-tooltip="This number represents the number of pending buyer signups.">&nbsp;</span>
                    </div>
                </div>
            );
        }
    });

    window.lo.pending_signups_widget = pending_signups_widget;
    window.require = require;

}).call(this);
