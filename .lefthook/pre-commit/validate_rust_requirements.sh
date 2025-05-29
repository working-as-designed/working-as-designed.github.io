#!/bin/bash
# filepath: .lefthook/pre-commit/validate_rust_requirements.sh

if [ -f Cargo.toml ]; then
  echo "🦀 Running cargo checks..."

  cargo check
  check_status=$?
  if [ $check_status -ne 0 ]; then
    echo "❌ cargo check failed. Please fix Rust build errors before committing."
    exit 1
  fi

  cargo test --quiet
  test_status=$?
  if [ $test_status -ne 0 ]; then
    echo "❌ cargo test failed. Please fix Rust test failures before committing."
    exit 1
  fi

  echo "✅ Rust code builds and tests pass."
else
  echo "ℹ️  No Cargo.toml found. Skipping Rust checks."
fi