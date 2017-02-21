(function() {
    window.lo = window.lo || {};

    function isLastDay(dt) {
        var test = new Date(dt.getTime());
        test.setDate(test.getDate() + 1);
        return test.getDate() === 1;
    }

    function generateDeliveryLink(delivery_day, user_type, process_date) {
        if (user_type == "B")
            view_deliveries_link = "/orders/" + delivery_day['order_id'];
        else
            MyDateString = process_date.getFullYear() + ('0' + (process_date.getMonth()+1)).slice(-2) + ('0' + process_date.getDate()).slice(-2)
            view_deliveries_link = "/admin/delivery_tools/pick_list_date/" + MyDateString;
        return view_deliveries_link;
    }

    var delivery_calendar_widget = React.createClass({
        propTypes: {
            userType: React.PropTypes.string,
            deliveries: React.PropTypes.array,
            numPendingDeliveries: React.PropTypes.number,
            pendingDeliveryAmount: React.PropTypes.string
        },

        isLastDay: function(dt) {
            var test = new Date(dt.getTime());
            test.setDate(test.getDate() + 1);
            return test.getDate() === 1;
        },

        generateWeeks: function(delivery_weeks, user_type) {
            var wks = '';
            var process_date;
            var last_day_of_month;
            var month_day, dow;
            var self = this;
            var i;
            var dlvr_href;
            var p_date;

            if (delivery_weeks) {
                $.each(delivery_weeks, function (k1, week) {
                    wks = wks + '<tr>';
                    $.each(week, function (k2, day) {
                        p_date = day['day'].split("-");
                        process_date = new Date(p_date[1] + '/' + p_date[2] + '/' + p_date[0] + ' 00:00:00');
                        month_day = process_date.getDate();
                        dow = process_date.getDay() + 1;
                        if (day['css_class'] == "cal-date")
                            dlvr_href=generateDeliveryLink(day, user_type, process_date);
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
            var view_deliveries_link;

            if (this.props.userType == "B")
                view_deliveries_link = "/orders"
            else
                view_deliveries_link = "/admin/delivery_tools"

            var weeks = this.generateWeeks(delivery_weeks, this.props.userType);

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
    window.require = require;

}).call(this);
