(function() {
    window.lo = window.lo || {};

    var dashboard = React.createClass({
        propTypes: {
            baseUrl: React.PropTypes.string.isRequired
        },

        getInitialState: function() {
            return {
                dashboard: {}
            };
        },

        componentWillMount: function() {
            this.updateDimensions();
            window.lo.DashboardStore.listen(this.onDashboardChange);
            window.lo.DashboardActions.loadDashboard(this.props.baseUrl);
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

        onDashboardChange: function(res) {
            this.setState({
                dashboard: res.dashboard
            });
        },

        render: function () {
            var self = this;

             return (
                 <div>
                     <div>
                         <div style={{float: 'left'}}>
                             <h1>Dashboard</h1>
                         </div>
                         <div style={{float: 'right'}}>
                             <lo.timeframe_picker />
                         </div>
                     </div>
                     <div className="row row--partial dashboard" style={{background: '#EEE', padding: 2}}>
                        <div className="column column--one-third" style={{padding: 2}}>
                            <lo.delivery_calendar_widget deliveries={self.state.dashboard.deliveries}/>
                        </div>
                        <div className="column column--one-third" style={{margin: 5, padding: 2}}>
                            <div>
                                <lo.sales_amount_widget
                                    totalSalesAmount={self.state.dashboard.totalSalesAmount}
                                    totalSalesAmountGraph={self.state.dashboard.totalSalesAmountGraph}
                                />
                            </div>
                            <div>
                                <lo.sales_avg_amount_widget
                                    avgSalesAmount={self.state.dashboard.avgSalesAmount}
                                />
                            </div>
                        </div>
                        <div className="column column--one-third" style={{margin: 5, padding: 2}}>
                            <div>
                                 <lo.sales_count_widget
                                     totalOrderCount={parseInt(self.state.dashboard.totalOrderCount)}
                                     totalOrderCountGraph={self.state.dashboard.totalOrderCountGraph}
                                 />
                            </div>
                            <div>
                                 <lo.payments_due_widget
                                     paymentsDueAmount={self.state.dashboard.paymentsDueAmount}
                                 />
                            </div>
                        </div>
                     </div>
                </div>
            );
        }
    });

    window.lo.dashboard = dashboard;
    module.exports = dashboard;

}).call(this);
