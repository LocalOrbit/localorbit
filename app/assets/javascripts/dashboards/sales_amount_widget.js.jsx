(function() {
    window.lo = window.lo || {};

    const Plotly = require('react-plotlyjs');

    var sales_amount_widget = React.createClass({
        propTypes: {
            userType: React.PropTypes.string,
            totalSalesAmount: React.PropTypes.string,
            totalSalesAmountGraph: React.PropTypes.array,
            lineColor: React.PropTypes.string,
            fillColor: React.PropTypes.string,
            axisTitle: React.PropTypes.string
        },

        render: function () {
            var self = this;
            var label_text;
            var labels=[], data_points=[];
            var j = this.props.totalSalesAmountGraph;
            var lineColor = this.props.lineColor;
            var fillColor = this.props.fillColor;
            var axisTitle = this.props.axisTitle;
            var totalSalesAmount;

            if (j) {
                $.each(j, function (i,v)
                {
                    labels.push(i);
                    data_points.push(parseFloat(v));
                });
            }

            let data = [
                {
                    type: 'scatter',
                    x: labels,
                    y: data_points,
                    line:{
                        shape:"spline"
                    },
                    marker:{
                        color: lineColor
                    },
                    mode:"lines+markers",
                    uid:"ab9b77",
                    connectgaps:false,
                    fillcolor: fillColor
                }
            ];
            let layout = {
                autosize: true,
                width: 290,
                height: 300,
                margin: {
                    l: 40,
                    r: 5,
                    t: 20,
                    b: 40,
                    autoexpand: true
                },
                yaxis:{
                    autorange:true,
                    showgrid:false,
                    zeroline:false,
                    autotick: false,
                    hoverformat: ".2f",
                    showexponent:"all",
                    tickprefix:"$",
                    tickfont:{
                        size:10
                    }
                },
                xaxis:{
                    autorange: true,
                    showgrid:false,
                    zeroline:false,
                    autotick: false,
                    title: axisTitle,
                    tickmode: 'linear',
                    rangemode: 'range',
                    range: [1,],
                    dtick: 1,
                    tick0: 1
                }
            };
            let config = {
                displayModeBar: false
            };

            if (this.props.userType == "S" || this.props.userType == "M")
                label_text = 'Total Sales';
            else
                label_text = 'Total Spend';

            if (this.props.totalSalesAmount)
                totalSalesAmount = this.props.totalSalesAmount;
            else
                totalSalesAmount = '$0';

            return (
                <div className="dashboard-widget large-widget">
                    <div className="top-section">
                        <div style={{float: "left"}}>
                            <div className="font-icon icon-coins"></div>
                        </div>
                        <div style={{float: "right"}}>
                            <div className="widget-value" id="totalSalesAmount">
                                {totalSalesAmount}
                            </div>
                            <div className="widget-label">
                                {label_text}
                            </div>
                        </div>
                        <div className="bottom-border"></div>
                    </div>
                    <Plotly className="SalesAmount" data={data} layout={layout} config={config}/>
                    <div style={{borderTop: '1px solid #EEE', padding: 3}}>
                        <a href="/admin/orders"><span style={{textTransform: 'uppercase', fontSize: 12, fontWeight: 'bold'}}>View Details ></span></a>
                        <span class="tooltip pull-right" data-tooltip="This number represents the total sales amount for the selected period.">&nbsp;</span>
                    </div>
                </div>
            );        }
    });

    window.lo.sales_amount_widget = sales_amount_widget;
    window.require = require;

}).call(this);
