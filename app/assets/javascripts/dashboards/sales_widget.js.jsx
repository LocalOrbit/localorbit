//(function() {
//    window.lo = window.lo || {};
//
//    var Chart = require('chartjs');
//    var React = require('react');
//    var Line = require("react-chartjs").Line;
//
//    var SalesWidget = React.createClass({
//
//        getInitialState: function () {
//            return {}
//        },
//        componentDidMount: function () {
//            return {}
//        },
//
//        render: function () {
//
//            var data = {
//                labels: ["January", "February", "March", "April", "May", "June", "July"],
//                datasets: [
//                    {
//                        label: "My First dataset",
//                        fillColor: "rgba(220,220,220,0.2)",
//                        strokeColor: "rgba(220,220,220,1)",
//                        pointColor: "rgba(220,220,220,1)",
//                        pointStrokeColor: "#fff",
//                        pointHighlightFill: "#fff",
//                        pointHighlightStroke: "rgba(220,220,220,1)",
//                        data: [65, 59, 80, 81, 56, 55, 40]
//                    },
//                    {
//                        label: "My Second dataset",
//                        fillColor: "rgba(151,187,205,0.2)",
//                        strokeColor: "rgba(151,187,205,1)",
//                        pointColor: "rgba(151,187,205,1)",
//                        pointStrokeColor: "#fff",
//                        pointHighlightFill: "#fff",
//                        pointHighlightStroke: "rgba(151,187,205,1)",
//                        data: [28, 48, 40, 19, 86, 27, 90]
//                    }
//                ]
//            };
//
//            var options = null;
//
//            return (
//                <Line data={data} options={options} />
//            );
//        }
//    });
//
//    window.lo.SalesWidget = SalesWidget;
//}).call(this);

//import React from "react";
//import { Line } from "react-chartjs";
//
//var chartOptions = {
//    bezierCurve : false,
//    datasetFill : false,
//    pointDotStrokeWidth: 4,
//    scaleShowVerticalLines: false,
//};
//
//var styles = {
//    "graphContainer" : {
//        "backgroundColor" : "#fff",
//        "height" : "235px",
//        "width" : "1150px",
//        "marginTop" : "15px",
//        "padding" : "20px"
//    }
//};
//
//export default class sales_widget extends React.Component {
//    constructor(props) {
//        super(props);
//
//        this.state = {
//            chartData: {
//                labels: ["January", "February", "March", "April", "May", "June", "July"],
//                datasets: [
//                    {
//                        fillColor: "#25BDFF",
//                        strokeColor: "#25BDFF",
//                        pointColor: "#25BDFF",
//                        pointStrokeColor: "#fff",
//                        pointHighlightFill: "#fff",
//                        pointHighlightStroke: "#25BDFF",
//                        data: [28, 48, 40, 19, 86, 27, 90]
//                    }
//                ]
//            }
//        };
//    }
//
//    render() {
//        return (
//            <div>
//                <div style={styles.graphContainer}>
//                    <Line data={this.state.chartData} options={chartOptions} width="1100" height="150" />
//                </div>
//            </div>
//        );
//    }
//};