<template>
    <div class="container">
        <h1 class="title">产品</h1>

        <!-- 添加新产品的表单 -->
        <div class="form-group">
            <input v-model="newProduct.name" placeholder="产品名称" class="form-control" />
            <input v-model="newProduct.brand" placeholder="品牌" class="form-control" />
            <input v-model="newProduct.unitPrice" placeholder="单价" class="form-control" />
            <input v-model="newProduct.quantity" placeholder="数量" class="form-control" />
            <button @click="insertProduct(newProduct)" class="btn btn-success">添加产品</button>
        </div>

        <!-- 显示产品信息的表格 -->
        <table class="table">
            <tr>
                <th>产品ID</th>
                <th>产品名称</th>
                <th>品牌</th>
                <th>单价</th>
                <th>数量</th>
                <th>操作</th>
            </tr>
            <tr v-for="product in products" :key="product.productID">
                <td>{{ product.productID }}</td>
                <td>{{ product.name }}</td>
                <td>{{ product.brand }}</td>
                <td>{{ product.unitPrice }}</td>
                <td>{{ product.quantity }}</td>
                <td>
                    <div class="btn-group">
                        <button class="btn btn-primary" @click="openUpdateModal(product)">修改</button>
                        <button class="btn btn-danger" @click="deleteProduct(product)">删除</button>
                    </div>
                </td>
            </tr>
        </table>

        <!-- 更新产品信息的模态对话框 -->
        <div v-if="showUpdateModal" class="modal">
            <div class="modal-content">
                <h2 class="modal-title">更新产品信息</h2>
                <input v-model="currentProduct.name" placeholder="产品名称" class="form-control" />
                <input v-model="currentProduct.brand" placeholder="品牌" class="form-control" />
                <input v-model="currentProduct.unitPrice" placeholder="单价" class="form-control" />
                <input v-model="currentProduct.quantity" placeholder="数量" class="form-control" />
                <div class="modal-buttons">
                    <button @click="updateProduct(currentProduct)" class="btn btn-primary">提交修改</button>
                    <button @click="showUpdateModal = false" class="btn btn-secondary">取消</button>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import axios from 'axios';

export default {
    name: 'Product',
    data() {
        return {
            products: [],
            newProduct: {
                productID: '',
                name: '',
                brand: '',
                unitPrice: '',
                quantity: ''
            },
            showUpdateModal: false, // 控制模态对话框的显示
            currentProduct: {} // 当前正在修改的产品
        }
    },
    created() {
        axios.get('/api/product/all')
            .then(response => {
                this.products = response.data;
            });
    },
    methods: {
        openUpdateModal(product) {
            this.currentProduct = Object.assign({}, product); // 复制产品对象
            this.showUpdateModal = true; // 显示模态对话框
        },
        updateProduct(product) {
            axios.post('/api/product/update', JSON.stringify(product), {
                headers: {
                    'Content-Type': 'application/json;charset=UTF-8'
                }
            })
                .then(response => {
                    // 更新成功
                    this.showUpdateModal = false; // 关闭模态对话框
                    // 更新列表中的信息
                    const index = this.products.findIndex(p => p.productID === product.productID);
                    this.products.splice(index, 1, product);
                }).catch(error => {
                    // 请求失败，弹出错误信息
                    this.$buefy.toast.open({
                        duration: 5000,
                        message: `添加产品失败：${error}`,
                        position: 'is-bottom',
                        type: 'is-danger'
                    });
                });
        },
        insertProduct(product) {
            axios.post('/api/product/insert', JSON.stringify(product), {
                headers: {
                    'Content-Type': 'application/json;charset=UTF-8'
                }
            })
                .then(response => {
                    // 插入成功
                    //this.products.push(product);
                    // 从服务器响应更新
                    const inserted = response.data;
                    this.products.push(inserted);
                }).catch(error => {
                    // 请求失败，弹出错误信息
                    this.$buefy.toast.open({
                        duration: 5000,
                        message: `添加产品失败：${error}`,
                        position: 'is-bottom',
                        type: 'is-danger'
                    });
                });
        },
        deleteProduct(product) {
            axios.get(`/api/product/delete/${product.productID}`)
                .then(response => {
                    // 删除成功
                    const index = this.products.indexOf(product);
                    this.products.splice(index, 1);
                });
        }
    }
}
</script>

<style src="../assets/table.css"></style>
