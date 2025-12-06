[![English](https://img.shields.io/badge/Language-English-blue)](README.md)

# Home Lab Kubernetes Infrastructure (IaC)

![License](https://img.shields.io/badge/license-MIT-blue)
![Terraform](https://img.shields.io/badge/Terraform-1.9+-purple)
![Ansible](https://img.shields.io/badge/Ansible-2.16+-red)
![Nix](https://img.shields.io/badge/Nix-Reproducible-blue)

**Proxmox VE 9** 上に Kubernetes クラスターを構築するための完全な **Infrastructure as Code (IaC)** リポジトリです。
本プロジェクトは、仮想ルーター (NFV) によるネットワーク分離と宣言的な構成管理を特徴とし、モダンで再現性の高いホームラボインフラストラクチャのアプローチを実証します。

## 🚀 主な機能

* **再現性のある環境:** **Nix & Direnv** を使用して開発ツール (Terraform, Ansible, kubectl) を管理します。ホストマシンへの手動インストールやバージョン不整合の問題を排除します。
* **ネットワーク機能仮想化 (NFV):** Fedora ベースの仮想ルーターを展開し、Kubernetes クラスターを内部ネットワークに分離します。NAT と IP マスカレードを通じて安全な通信を確立します。
* **堅牢なネットワーク:** VirtIO ドライバーでのパケットドロップを防ぐための最適化設定 (TSO/GSO 無効化) や、Calico CNI との互換性のための NetworkManager 調整を含みます。
* **モダンな Proxmox サポート:** **bpg/proxmox** プロバイダーを使用し、Proxmox VE 9+ との完全な互換性を提供します。
* **GitOps 対応:** **ArgoCD** と **MetalLB** を自動的にブートストラップし、即座にアプリケーションデプロイが可能な状態にします。
* **宣言的な構成管理:**
    * **Terraform:** VM のライフサイクル (コンピュート, ネットワーク, ストレージ) をパラメータ化されたリソースサイズで管理します。
    * **Ansible:** OS 設定、ルーター構築、Kubernetes (Kubeadm) のブートストラップを一貫して管理します。

## 🏗️ アーキテクチャ

```mermaid
graph TD
    User[Developer PC] -->|Nix/Direnv| DevEnv[Dev Shell]
    DevEnv -->|Terraform| PVE[Proxmox VE 9]

    subgraph Proxmox Virtual Environment
        Router[<b>Virtual Router</b><br>Fedora Cloud]
        K8s[<b>K8s Node</b><br>Fedora Cloud]

        Router -- WAN (vmbr0) --- HomeLAN((Home LAN))
        Router -- Internal (vmbr1) --> K8s
    end

    DevEnv -->|Ansible| Router
    DevEnv -->|Ansible via Router| K8s
````

## 🛠️ 技術スタックと選定理由

| カテゴリ | 技術 | 選定理由 |
| :--- | :--- | :--- |
| **開発環境** | **Nix + Direnv** | 異なるマシン間でのツールバージョンの一貫性を保証し、ホスト OS をクリーンに保つため。 |
| **プロビジョニング** | **Terraform** | インフラライフサイクル管理の業界標準。v9 互換性のために `bpg/proxmox` を採用。 |
| **構成管理** | **Ansible** | エージェントレスで軽量。ルーターのネットワーク設定から K8s のブートストラップまでを一貫して管理します。 |
| **ネットワーク** | **Linux Router (NFV)** | 物理ネットワーク機器の設定を変更することなく、IaC だけで完全に分離されたネットワーク環境 (SDN) を構築するため。 |
| **仮想化** | **Proxmox VE** | 強力なオープンソースの Type-1 ハイパーバイザー。 |
| **OS** | **Fedora Cloud** | 最新のカーネル機能と SELinux 統合を提供し、モダンなコンテナワークロードに最適であるため。 |

## ⚡ クイックスタート

### 前提条件

  * Nix がインストールされていること
  * Direnv がインストールされていること
  * Proxmox VE 8.x または 9.x 環境
  * **ハードウェアリソース:** ホストに十分な RAM があることを確認してください。デフォルト構成では K8s ノードに **20GB RAM** を割り当てます (`terraform.tfvars` で変更可能)。

### 1\. 開発環境のセットアップ

ディレクトリに移動するだけで、Nix が Terraform, Ansible などのツールを自動セットアップします。

```bash
direnv allow
```

### 2\. クレデンシャルとリソースの設定

サンプルファイルをコピーし、Proxmox の認証情報とリソースサイズを定義します。

```bash
cp terraform.tfvars.example terraform.tfvars
# pve_endpoint, pve_user, token, ssh_key などを編集
# 必要に応じて vm_memory や vm_cpu_cores を調整
```

### 3\. インフラのプロビジョニング (Terraform)

仮想ルーターと Kubernetes ノードの VM を作成します。

```bash
terraform init
terraform plan
terraform apply
```

### 4\. ネットワークとクラスターの構築 (Ansible)

インベントリファイルを作成し、**ルーター構築 → クラスター構築** の順に Playbook を実行します。

```bash
cp inventory.ini.example inventory.ini
# ルーターと K8s ノードの IP アドレスを編集

# 1. 仮想ルーターのセットアップ (NAT/Firewall 有効化 & パケットドロップ対策)
ansible-playbook -i inventory.ini router.yml

# 2. Kubernetes クラスター構築 (Kubeadm, Calico, MetalLB, ArgoCD)
ansible-playbook -i inventory.ini site.yml
```

## 🔜 ロードマップ

  * [x] GitOps ベースのアプリデプロイのための **ArgoCD** 統合
  * [x] 内部 L2 ロードバランシングのための **MetalLB** 設定
  * [ ] 自動依存関係更新のための **Renovate** 実装
  * [ ] ポート開放なしで安全なリモートアクセスを行うための **Cloudflare Tunnel** 統合
  * [ ] 分散ブロックストレージとバックアップのための **Longhorn** または **Rook/Ceph** デプロイ
  * [ ] クラスター監視とアラートのための **Prometheus & Grafana** スタック
  * [ ] ログ集約のための **Loki** または **Fluent Bit**
  * [ ] GitOps でシークレットを管理するための **Sealed Secrets** または **External Secrets Operator**

## 📝 ライセンス

本プロジェクトは MIT ライセンスの下で公開されています。
