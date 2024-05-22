<template>
    <div class="container">
        <h1 class="title">统计</h1>

        <!-- 每日销售额 -->
        <div class="statistics-group">
            <h2 class="statistics-title">每日销售额</h2>
            {{ dailySales.totalSales }}
        </div>

        <!-- 每月销售额 -->
        <div class="statistics-group">
            <h2 class="statistics-title">每月销售额</h2>
            {{ monthlySales.totalSales }}
        </div>

        <!-- 每年销售额 -->
        <div class="statistics-group">
            <h2 class="statistics-title">每年销售额</h2>
            {{ yearlySales.totalSales }}
        </div>

        <!-- 总支出 -->
        <div class="statistics-group">
            <h2 class="statistics-title">总支出</h2>
            员工: {{ totalExpense.staffExpense }}<br/>
            进货: {{ totalExpense.productExpense }}
        </div>

        <!-- 总收入 -->
        <div class="statistics-group">
            <h2 class="statistics-title">总收入</h2>
            {{ totalIncome.income }}
        </div>
    </div>
</template>

<script>
import axios from 'axios';

export default {
    name: 'Statistics',
    data() {
        return {
            dailySales: {},
            monthlySales: {},
            yearlySales: {},
            totalExpense: {},
            totalIncome: {}
        }
    },
    created() {
        axios.get('/api/statistics/sales/daily')
            .then(response => {
                this.dailySales = response.data;
            });
        axios.get('/api/statistics/sales/monthly')
            .then(response => {
                this.monthlySales = response.data;
            });
        axios.get('/api/statistics/sales/yearly')
            .then(response => {
                this.yearlySales = response.data;
            });
        axios.get('/api/statistics/expense')
            .then(response => {
                const expense = (response.data == null ? {staffExpense: 0,productExpense: 0} : response.data);
                this.totalExpense = expense;
            });
        axios.get('/api/statistics/income')
            .then(response => {
                const income = (response.data == null ? 0 : response.data);
                this.totalIncome = income;
            });
    }
}
</script>

<style src="../assets/table.css"></style>
