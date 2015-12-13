(function() {
    window.lo = window.lo || {};

    function isLastDay(dt) {
        var test = new Date(dt.getTime());
        test.setDate(test.getDate() + 1);
        return test.getDate() === 1;
    }

    var delivery_calendar_widget = React.createClass({
        propTypes: {
            userType: React.PropTypes.string.isRequired,
            deliveries: React.PropTypes.array.isRequired,
            numPendingDeliveries: React.PropTypes.number.isRequired,
            pendingDeliveryAmount: React.PropTypes.string.isRequired
        },

        isLastDay: function(dt) {
            var test = new Date(dt.getTime());
            test.setDate(test.getDate() + 1);
            return test.getDate() === 1;
        },

        generateWeeks: function(delivery_weeks) {
            var wks = '';
            var process_date;
            var last_day_of_month;
            var month_day, dow;
            var self = this;
            var i;
            var dlvr_href;

            if (delivery_weeks) {
                $.each(delivery_weeks, function (k1, week) {
                    wks = wks + '<tr>';
                    $.each(week, function (k2, day) {
                        process_date = new Date(day['day']);
                        month_day = process_date.getDate();
                        dow = process_date.getDay() + 1;
                        if (day['css_class'] == "cal-date")
                            dlvr_href="/admin/delivery_tools";
                        else
                            dlvr_href='#';
                        wks = wks + '<td class="' + day['css_class'] + '"><a style="color: white" href=' + dlvr_href + '>' + month_day  + '</a></td>';
                        last_day_of_month = self.isLastDay(process_date);
                        if (last_day_of_month) {
                            wks = wks + '</tr><tr><td colspan="7" class="cal-date blank"></td></tr><tr>';
                            for(i = 1; i <= dow; i++)
                                wks = wks + '<td class="cal-date blank"></td>';
                        }
                    });

                    wks = wks + '</tr>';
                });
            }
            return (<table className="calendar"><tbody dangerouslySetInnerHTML={{__html: wks}} /></table>);
        },

        render: function () {

            var delivery_weeks = this.props.deliveries;
            var weeks = this.generateWeeks(delivery_weeks);
            var view_deliveries_link;

            if (this.props.userType == "S")
                view_deliveries_link = "/admin/orders"
            else
                view_deliveries_link = "/admin/delivery_tools"

            return (
                <div className="dashboard-widget large-widget deliveries">
                    <div style={{fontSize: 24, textAlign: 'left', padding: 10, color: "#FFF"}}>
                        {this.props.numPendingDeliveries} Upcoming Deliveries
                    </div>
                    <div className="bottom-border deliveries"></div>
                    <br/><br/>
                    {weeks}
                    <div className="bottom-border deliveries"></div>
                    <div className="top-section">
                        <lo.pending_delivery
                            pendingDeliveryAmount={this.props.pendingDeliveryAmount}
                        />
                    </div>
                    <div className="bottom-border deliveries"></div>
                    <br/><br/>
                    <div style={{margin: "0 auto", width: 165}}>
                        <a href={view_deliveries_link} className="btn btn--primary" style={{textAlign: "center"}}>View All Deliveries</a>
                    </div>
                    <br/>
                </div>
            );
        }
    });

    window.lo.delivery_calendar_widget = delivery_calendar_widget;
    module.exports = delivery_calendar_widget;

}).call(this);
