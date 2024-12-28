<template>
  <div class="logs-view container">
    <b-field class="member-finder">
      <b-autocomplete
        v-model="searchQuery"
        :data="autocompleteMembers"
        field="name"
        :loading="$apollo.loading"
        @select="handleMemberSelect"
        icon="magnify"
        placeholder="Filter by Member"
        size="is-small"
      >
        <template #empty>No results found</template>
      </b-autocomplete>
    </b-field>

    <table v-if="logsData.length">
      <thead>
        <tr>
          <th>ID</th>
          <th>Admin</th>
          <th>Action</th>
          <th>Properties</th>
          <th>Timestamp</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="log in logsData" :key="log.id">
          <td>{{ log.id }}</td>
          <td>{{ log.teamMember.name }}</td>
          <td>{{ log.name }}</td>
          <td>{{ log.properties }}</td>
          <td>{{ formatDate(log.time) }}</td>
        </tr>
      </tbody>
    </table>
    <div v-else-if="!$apollo.loading">
      <p class="no-logs-message">
        No logs found. Try adjusting your filters or search criteria.
      </p>
    </div>

    <Pagination
      :current-page="pagination.currentPage"
      :total-pages="pagination.totalPages"
      @page-changed="handlePageChange"
    />

    <b-loading v-model="$apollo.loading" :is-full-page="false" />
  </div>
</template>

<script>
  import gql from 'graphql-tag'
  import Pagination from 'Admin/components/shared/pagination.vue';

  export default {
    components: {
      Pagination,
    },

    data() {
      return {
        searchQuery: '',
        memberId: null,
        logsData: [],
        pagination: {
          currentPage: 1,
          totalPages: 0,
        },
      };
    },

    methods: {
      formatDate(timestamp) {
        return new Date(timestamp).toLocaleString();
      },

      handleMemberSelect(member) {
        if (!member) return;

        this.$router.push(`/logs?member_id=${member.id}`)
      },

      handlePageChange(page) {
        this.pagination.currentPage = page;
        this.$apollo.queries.logs.refetch();
      },
    },

    apollo: {
      // Fetch members for the autocomplete
      teamMemberSearch: {
        query: gql`
          query teamMemberSearch($query: String!) {
            teamMemberSearch(query: $query) {
              id
              name
            }
          }
        `,
        variables() {
          return {
            query: this.searchQuery,
          };
        },
      },
      logs: {
        query: gql`
          query logs($memberId: ID, $page: Int, $perPage: Int) {
            logs(memberId: $memberId, page: $page, perPage: $perPage) {
              data {
                id
                time
                name
                properties
                teamMember {
                  id
                  email
                  name
                }
              }
              meta {
                currentPage
                totalPages
              }
            }
          }
        `,
        variables() {
          return {
            memberId: parseInt(this.$route.query.member_id) || null,
            page: this.pagination.currentPage || 1,
            perPage: 10,
          }
        },
        update(data) {
          this.logsData = data.logs.data;
          this.pagination = data.logs.meta;
        },
      },
    },

    computed: {
      autocompleteMembers() {
        return this.$apollo.loading ? [] : this.teamMemberSearch;
      },
    },
  }
</script>

<style scoped>
  .logs-view {
    padding: 20px;
  }

  .member-finder {
    .autocomplete .dropdown-menu {
      width: auto;
    }
  }

  .pagination-controls {
    display: flex;
    justify-content: center;
    align-items: center;
    margin-top: 20px;
  }

  .pagination-controls button {
    margin: 0 10px;
    padding: 5px 10px;
    font-size: 14px;
    cursor: pointer;
  }

  .pagination-controls button:disabled {
    cursor: not-allowed;
    opacity: 0.6;
  }

  .no-logs-message {
    text-align: center;
    font-size: 18px;
    color: #888;
    margin-top: 20px;
  }

  .pagination-controls button.active {
    font-weight: bold;
    background-color: #007bff;
    color: white;
  }

  table {
    width: 100%;
    border-collapse: collapse;
  }

  th, td {
    padding: 8px 12px;
    border: 1px solid #ddd;
  }

  th {
    background-color: #f4f4f4;
  }

  tr:nth-child(even) {
    background-color: #f9f9f9;
  }

  tr:hover {
    background-color: #f1f1f1;
  }

  input {
    margin-bottom: 20px;
    padding: 8px;
    font-size: 16px;
    width: 200px;
  }
</style>
