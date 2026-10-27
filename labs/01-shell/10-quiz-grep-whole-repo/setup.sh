#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
mkdir -p shop/payments shop/config shop/tests
printf '%s\n' \
  'from flask import Flask' \
  'from payments.client import charge, issue_refund' \
  '# TODO: add rate limiting' \
  'app = Flask(__name__)' \
  '' \
  '@app.route("/refund", methods=["POST"])' \
  'def refund(order_id):' \
  '    return issue_refund(order_id)' \
  > shop/app.py
printf '%s\n' \
  'import requests' \
  'STRIPE_API_KEY="sk_live_9f8e7d6c5b4a"' \
  '# TODO: read the key from the environment instead' \
  'def charge(order_id, amount):' \
  '    return requests.post("https://api.stripe.com/charge", auth=STRIPE_API_KEY)' \
  > shop/payments/client.py
printf '%s\n' \
  'from payments.client import charge' \
  '# TODO: support partial refunds' \
  'def refund_order(order_id):' \
  '    # was called issue_refund in the old design doc' \
  '    return charge(order_id, 0)' \
  > shop/payments/refunds.py
printf '%s\n' \
  'import os' \
  'STRIPE_API_KEY = os.environ["STRIPE_API_KEY"]' \
  'DEBUG = False' \
  > shop/config/settings.py
printf '%s\n' \
  'from app import refund' \
  'def test_refund_calls_issue_refund():' \
  '    # TODO: use a fake payments client' \
  '    assert refund(42) is not None' \
  > shop/tests/test_refund.py
printf '%s\n' \
  'STRIPE_API_KEY=sk_live_9f8e7d6c5b4a' \
  'DATABASE_URL=postgres://shop:hunter2@db:5432/shop' \
  > shop/.env
printf '%s\n' \
  'STRIPE_API_KEY=' \
  'DATABASE_URL=' \
  > shop/.env.example
printf '%s\n' \
  '# Shop' \
  'TODO: write the setup steps' \
  'TODO: document issue_refund' \
  > shop/README.md
banner "10 search a whole repo (Quiz-style): grep -r, -n, -l, -E, counting across files"
