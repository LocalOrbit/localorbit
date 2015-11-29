(function() {
    window.lo = window.lo || {};

    var delivery_calendar_widget = React.createClass({
        propTypes: {
        },

        render: function () {

        /*
             <% delivery_weeks.each do |w| %>
             <tr>
             <% w.each do |d| %>
             <% if d[:delivery_id] %>
             <td onclick="setDelivery(this,'<%= d[:day] %>',<%= d[:delivery_id] %>)"
             class="<%= d[:css_class] %>"><%= d[:day].day %></td>
             <% else %>
             <td class="<%= d[:css_class] %>"><%= d[:day].day %></td>
             <% end %>
             <% end %>
             </tr>
             <% end %>
         */

            var weekRow = '';
            return (
                <div style={{background: "#666", color: "#FFF", width: 300, height: 500}}>
                    <div style={{fontSize: 24, textAlign: 'left', padding: 10}}>
                        Upcoming Deliveries
                    </div>
                    <table className="calendar">
                        {weekRow}
                    </table>
                </div>
            );
        }
    });

    window.lo.delivery_calendar_widget = delivery_calendar_widget;
    module.exports = delivery_calendar_widget;

}).call(this);
