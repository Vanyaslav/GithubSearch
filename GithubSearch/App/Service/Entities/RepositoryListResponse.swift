//
//  RepositoryListEntity.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 08/01/2022.
//

import Foundation

struct RepositoryListResponse: Codable {
    let incomplete_results: Bool
    let items: [RepositoryResponse]?
    let total_count: UInt64
}

struct RepositoryResponse: Codable {
    let allow_forking: Bool?
    let archive_url: String?
    let archived: Bool?
    let assignees_url: String?
    let blobs_url: String?
    let branches_url: String?
    let clone_url: String?
    let collaborators_url: String?
    let comments_url: String?
    let commits_url: String?
    let compare_url: String?
    let contents_url: String?
    let contributors_url: String?
    let created_at: String?
    let default_branch: String?
    let deployments_url: String?
    let description: String?
    let disabled: Bool
    let downloads_url: String
    let events_url: String?
    let fork: Bool
    let forks: Int?
    let forks_url: String?
    let full_name: String
    let git_commits_url: String?
    let git_refs_url: String?
    let git_tags_url: String?
    let git_url: String
    let has_downloads: Bool
    let has_issues: Bool
    let has_pages: Bool
    let has_projects: Bool
    let has_wiki: Bool
    let homepage: String?
    let hooks_url: String
    let html_url: String
    let id: UInt64
    let is_template: Bool
    let issue_comment_url: String?
    let issue_events_url: String?
    let issues_url: String?
    let keys_url: String?
    let labels_url: String?
    let language: String?
    let languages_url: String
    let license: License
    let merges_url: String?
    let milestones_url: String?
    let mirror_url: String?
    let name: String
    let node_id: String
    let notifications_url: String?
    let open_issues: Int?
    let open_issues_count: Int?
    let owner: Owner
    let permissions: Permissions?
    let `private`: Bool
    let pulls_url: String?
    let pushed_at: String?
    let releases_url: String?
    let score: Int
    let size: UInt64
    let ssh_url: String?
    let stargazers_count: UInt64?
    let stargazers_url: String?
    let statuses_url: String?
    let subscribers_url: String?
    let subscription_url: String?
    let svn_url: String?
    let tags_url: String?
    let teams_url: String?
    let topics: [String]
    let trees_url: String
    let updated_at: String?
    let url: String
    let visibility: String?
    let watchers: UInt64?
    let watchers_count: UInt64?
}
// TODO
struct Permissions: Codable {

}
// TODO
struct Owner: Codable {

}
// TODO
struct License: Codable {

}
