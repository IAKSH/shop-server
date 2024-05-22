<template>
    <div id="app">
        <div id="sidebar">
            <ul>
                <li @click="changePage('Statistics')">统计</li>
                <li @click="changePage('Sales')">售出</li>
                <li @click="changePage('Source')">货源</li>
                <li @click="changePage('Products')">产品</li>
                <li @click="changePage('Purchase')">进货</li>
                <li @click="changePage('Member')">会员</li>
                <li @click="changePage('Staff')">员工</li>
            </ul>
        </div>
        <div id="content">
            <!-- Your page content goes here -->
        </div>
    </div>
</template>

<script>
export default {
    name: 'Sidebar',
    methods: {
        changePage(page) {
            this.$emit('change-page', page);
        }
    }
}
</script>

<style>
#app {
    display: flex;
}

#sidebar {
    position: fixed;
    width: 200px;
    height: 100vh;
    background: linear-gradient(to bottom, #f8f9fa, #e9ecef);
    padding: 20px;
    backdrop-filter: blur(10px);
    box-shadow: 0 4px 12px 0 rgba(0, 0, 0, 0.2), 0 2px 10px 0 rgba(0, 0, 0, 0.19);
}

#content {
    margin-left: 220px; /* sidebar width + some padding */
}

#sidebar ul {
    list-style-type: none;
    padding: 0;
}

#sidebar ul li {
    cursor: pointer;
    margin-bottom: 20px;
    padding: 10px;
    border-radius: 5px;
    transition: background-color 0.3s ease;
}

#sidebar ul li:hover {
    background-color: rgba(0, 0, 0, 0.1);
}
</style>
