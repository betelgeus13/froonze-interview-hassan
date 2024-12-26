<template>
  <div>
    <div class="level header">
      <div class="level-right">
        <div class="level-item">
          Filters
        </div>
      </div>
    </div>
    <div v-if="logs" class="main-view container">
      <label for="member-id">Filter by Member ID:</label>
      <b-field class="member-finder">
        <b-autocomplete
          v-model="searchQuery"
          :data="autocompleteMembers"
          field="name"
          :loading="$apollo.loading"
          @select="handleMemberSelect"
          icon="magnify"
          placeholder="Find a member"
          size="is-small"
        >
          <template #empty>No results found</template>
        </b-autocomplete>
      </b-field>

      <table>
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
          <tr v-for="log in logs" :key="log.id">
            <td>{{ log.id }}</td>
            <td>{{ log.teamMember.name }}</td>
            <td>{{ log.name }}</td>
            <td>{{ log.properties }}</td>
            <td>{{ new Date(log.time).toLocaleString() }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <b-loading v-model="$apollo.loading" :is-full-page="false" />
  </div>
</template>

<script>
  import gql from 'graphql-tag'
  import ShopFinder from 'Admin/components/shop_finder.vue'
  import Actions from 'Admin/components/shared/actions.vue'

  export default {
    components: {
      ShopFinder,
      Actions,
    },

    data() {
      return {
        searchQuery: '', // Search input for the autocomplete
        memberId: null,  // Selected member ID
      };
    },

    methods: {
      handleMemberSelect(member) {
        if (!member) return;

        this.$router.push(`/logs?member_id=${member.id}`)
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
          query logs($memberId: ID) {
            logs(memberId: $memberId) {
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
          }
        `,
        variables() {
          return {
            memberId: parseInt(this.$route.query.member_id),
          }
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
  .member-finder {
    .autocomplete .dropdown-menu {
      width: auto;
    }
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

  input {
    margin-bottom: 20px;
    padding: 8px;
    font-size: 16px;
    width: 200px;
  }
</style>
