(function() {
    window.lo = window.lo || {};

    const Plotly = require('react-plotlyjs');

    var sales_amount_widget = React.createClass({
        propTypes: {
            userType: React.PropTypes.string,
            graphLabels: React.PropTypes.array,
            totalSalesAmount: React.PropTypes.string,
            totalSalesAmountGraph: React.PropTypes.array,
            lineColor: React.PropTypes.string,
            fillColor: React.PropTypes.string,
            axisTitle: React.PropTypes.string
        },

        render: function () {
            var self = this;
            var label_text;
            var labels = [], data_points = [];
            var l = this.props.graphLabels;
            var j = this.props.totalSalesAmountGraph;
            var lineColor = this.props.lineColor;
            var fillColor = this.props.fillColor;
            var axisTitle = this.props.axisTitle;
            var totalSalesAmount;
            var salesAmountGraph;
            var rangeSetting;
            var tickFormat;
            var axisType;
            var dTick;

            if (l) {
                $.each(l, function (i, v) {
                    if (v)
                        labels.push(v);
                });
            }

            if (j) {
                $.each(j, function (i, v) {
                    if (v)
                        data_points.push(parseFloat(v));
                });
            }

            let data = [
                {
                    type: 'scatter',
                    x: labels,
                    y: data_points,
                    line: {
                        shape: "spline"
                    },
                    marker: {
                        color: lineColor,
                        size: 10
                    },
                    mode: "lines+markers",
                    uid: "ab9b77",
                    connectgaps: true,
                    fillcolor: fillColor
                }
            ];

            if (axisTitle == 'Hour of Day') {
                axisType = '-';
                dTick = 2;
            }
            else if (axisTitle == 'Month of Year') {
                axisType = '-';
                dTick = 1;
            }
            else if (axisTitle == 'Day of Month') {
                axisType = '-';
                dTick = 1;
            }
            else if (axisTitle == 'Last 7 Days') {
                if (labels.length > 1) {
                    tickFormat = '%e';
                    axisType = 'date';
                }
                else {
                    axisType = 'category'
                    labels[0] = new Date(labels[0]).getUTCDay()
                }
            }

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
                    type: axisType,
                    tickformat:tickFormat,
                    title: axisTitle,
                    dtick: dTick,
                    tickfont:{
                        size:10
                    }
                }
            };
            let config = {
                displayModeBar: false
            };

            if (this.props.userType == "S" || this.props.userType == "M")
                label_text = 'Total Sales';
            else if (this.props.userType == "P")
                label_text = 'Total Purchases';
            else
                label_text = 'Total Spend';

            if (this.props.totalSalesAmount)
                totalSalesAmount = this.props.totalSalesAmount;
            else
                totalSalesAmount = '$0';

            if (this.props.totalSalesAmount && this.props.totalSalesAmount != '$0') {
            salesAmountGraph = (
                <div>
                    <Plotly className="SalesAmount" data={data} layout={layout} config={config}/>
                    <div style={{borderTop: '1px solid #EEE', padding: 3, marginTop: 15}}>
                        <a href="/admin/orders"><span style={{textTransform: 'uppercase', fontSize: 12, fontWeight: 'bold'}}>View Details ></span></a>
                        <span className="tooltip pull-right" data-tooltip="This number represents the total sales amount for the selected period.">&nbsp;</span>
                    </div>
                </div>);
            }
            else
            salesAmountGraph = (<div style={{height: '300px', width: '290px', lineHeight: '300px', verticalAlign: 'middle', color: '#AAA', background: '#FFF', fontSize: '24px', textAlign: 'center'}}>No Data Available</div>);

            return (
                <div className="dashboard-widget large-widget">
                    <div className="top-section">
                        <div style={{float: "left"}}>
                            <div className="font-icon icon-coins"></div>
                        </div>
                        <div style={{float: "right", paddingRight:10}}>
                            <div className="widget-value" id="totalSalesAmount">
                                {totalSalesAmount}
                            </div>
                            <div className="widget-label">
                                {label_text}
                            </div>
                        </div>
                        <div className="bottom-border"></div>
                    </div>
                    {salesAmountGraph}
                </div>
            );        }
    });

    window.lo.sales_amount_widget = sales_amount_widget;
    window.require = require;

}).call(this);
