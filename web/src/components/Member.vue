<template>
    <div class="container">
        <h1 class="title">会员</h1>

        <!-- 添加新会员的表单 -->
        <div class="form-group">
            <input v-model="newMember.name" placeholder="姓名" class="form-control" />
            <input v-model="newMember.membershipStartDate" placeholder="会员开始日期" class="form-control" />
            <input v-model="newMember.membershipEndDate" placeholder="会员结束日期" class="form-control" />
            <button @click="insertMember(newMember)" class="btn btn-success">添加会员</button>
        </div>

        <!-- 显示会员信息的表格 -->
        <table class="table">
            <tr>
                <th>姓名</th>
                <th>会员开始日期</th>
                <th>会员结束日期</th>
                <th>操作</th>
            </tr>
            <tr v-for="member in members" :key="member.memberID">
                <td>{{ member.name }}</td>
                <td>{{ member.membershipStartDate }}</td>
                <td>{{ member.membershipEndDate }}</td>
                <td>
                    <div class="btn-group">
                        <button class="btn btn-primary" @click="openUpdateModal(member)">修改</button>
                        <button class="btn btn-danger" @click="deleteMember(member)">删除</button>
                    </div>
                </td>
            </tr>
        </table>

        <!-- 更新会员信息的模态对话框 -->
        <div v-if="showUpdateModal" class="modal">
            <div class="modal-content">
                <h2 class="modal-title">更新会员信息</h2>
                <input v-model="currentMember.name" placeholder="姓名" class="form-control" />
                <input v-model="currentMember.membershipStartDate" placeholder="会员开始日期" class="form-control" />
                <input v-model="currentMember.membershipEndDate" placeholder="会员结束日期" class="form-control" />
                <div class="modal-buttons">
                    <button @click="updateMember(currentMember)" class="btn btn-primary">提交修改</button>
                    <button @click="showUpdateModal = false" class="btn btn-secondary">取消</button>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import axios from 'axios';

export default {
    name: 'Member',
    data() {
        return {
            members: [],
            newMember: {
                name: '',
                membershipStartDate: '',
                membershipEndDate: ''
            },
            showUpdateModal: false, // 控制模态对话框的显示
            currentMember: {} // 当前正在修改的会员
        }
    },
    created() {
        axios.get('/api/member/all')
            .then(response => {
                this.members = response.data;
            });
    },
    methods: {
        openUpdateModal(member) {
            this.currentMember = Object.assign({}, member); // 复制会员对象
            this.showUpdateModal = true; // 显示模态对话框
        },
        updateMember(member) {
            axios.post('/api/member/update', member, {
                headers: {
                    'Content-Type': 'application/json;charset=UTF-8'
                }
            })
                .then(response => {
                    // 更新成功
                    this.showUpdateModal = false; // 关闭模态对话框
                    const index = this.members.findIndex(m => m.memberID === member.memberID);
                    this.members.splice(index, 1, member);
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
        insertMember(member) {
            axios.post('/api/member/insert', member, {
                headers: {
                    'Content-Type': 'application/json;charset=UTF-8'
                }
            })
                .then(response => {
                    // 插入成功
                    //this.members.push(member);
                    // 从服务器响应更新
                    const inserted = response.data;
                    this.members.push(inserted);
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
        deleteMember(member) {
            axios.get(`/api/member/delete/${member.memberID}`)
                .then(response => {
                    // 删除成功
                    const index = this.members.indexOf(member);
                    this.members.splice(index, 1);
                });
        }
    }
}
</script>

<style src="../assets/table.css"></style>
