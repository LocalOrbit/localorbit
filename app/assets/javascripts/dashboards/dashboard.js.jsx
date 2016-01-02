(function() {
    window.lo = window.lo || {};

    var dashboard = React.createClass({
        propTypes: {
            baseUrl: React.PropTypes.string.isRequired
        },

        getInitialState: function () {
            return {
                dashboard: {},
                interval: "1",
                selectedEntity: "B"
            };
        },

        componentWillMount: function () {
            this.updateDimensions();
            window.lo.DashboardStore.listen(this.onDashboardChange);
            window.lo.DashboardActions.loadDashboard(this.props.baseUrl);
        },

        componentDidMount: function () {
            window.addEventListener('resize', this.updateDimensions);
        },

        componentWillUnmount: function () {
            window.removeEventListener('resize', this.updateDimensions);
        },

        updateDimensions: function () {
            this.setState({width: $(window).width()});
        },

        onIntervalChanged: function (value) {
            window.lo.DashboardStore.interval = value;
            this.setState({interval:value});
        },

        onSelectedEntityChanged: function (value) {
            window.lo.DashboardStore.selectedEntity = value;
            this.setState({selectedEntity:value});
        },

        onDashboardChange: function(res) {
            this.setState({
                dashboard: res.dashboard
            });
        },

        render: function () {
            var self = this;
            var buyer_supplier_picker;
            var bottomRightWidget;
            var uType;

            if (this.state.dashboard.showEntityPicker)
                buyer_supplier_picker = (<lo.buyer_supplier_picker callbackParent={this.onSelectedEntityChanged}/>);
            else
                buyer_supplier_picker = ('');

            if ((self.state.dashboard.showEntityPicker && (self.state.selectedEntity == "S" ) || self.state.dashboard.userType == "S" || (self.state.selectedEntity == "B" ) || self.state.dashboard.userType == "B"))
                bottomRightWidget = (<lo.payments_due_widget paymentsDueAmount={self.state.dashboard.paymentsDueAmount} />);
            else if (self.state.dashboard.userType == "M")
                bottomRightWidget = (<lo.pending_signups_widget numPendingBuyers={self.state.dashboard.numPendingBuyers} />);
            else
                bottomRightWidget = ('');

            if (self.state.dashboard.userType)
                uType = self.state.dashboard.userType;
            else
                if (self.state.selectedEntity == "S")
                    uType = "S";
                else
                    uType = "B";

            return (
                 <div>
                     <div>
                         <div style={{float: 'left'}}>
                             <h1>Dashboard</h1>
                         </div>
                         <div style={{float: 'right'}}>
                             <lo.timeframe_picker callbackParent={this.onIntervalChanged}/>
                         </div>
                         <div style={{float: 'right', marginRight: 15}}>
                             {buyer_supplier_picker}
                         </div>
                     </div>
                     <div className="row row--partial dashboard" style={{background: '#EEE', padding: 2}}>
                        <div className="column column--one-third" style={{padding: 2}}>
                            <lo.delivery_calendar_widget
                                userType={uType}
                                deliveries={self.state.dashboard.deliveries}
                                numPendingDeliveries={self.state.dashboard.numPendingDeliveries}
                                pendingDeliveryAmount={self.state.dashboard.pendingDeliveryAmount}
                            />
                        </div>
                        <div className="column column--one-third" style={{margin: 5, padding: 2}}>
                            <div>
                                <lo.sales_amount_widget
                                    userType={uType}
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
                                {bottomRightWidget}
                            </div>
                        </div>
                     </div>
                </div>
            );
        }
    });

    window.lo.dashboard = dashboard;

}).call(this);
