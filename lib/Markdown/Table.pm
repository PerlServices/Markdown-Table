package Markdown::Table;

# ABSTRACT: Create and parse tables in Markdown

use strict;
use warnings;

use Moo;

use Text::ASCIITable 0.22;
use Data::Printer;

has cols => (
    is  => 'rwp',
    isa => sub { ref $_[0] and 'ARRAY' eq ref $_[0] },
);

has rows => (
    is  => 'rwp',
    isa => sub { ref $_[0] and 'ARRAY' eq ref $_[0] },
);

sub parse {
    my ($class, $markdown, $options) = @_;

    $options //= {};

    my @found_tables = $markdown =~ m{
        (
            ^\|[^\n]+\n
            ^\|(?:-{3,}\|)+\n
            (?:
                ^\|[^\n]+\n
            )+
        )
    }xmg;

    if ( $options->{nuclino} ) {
        push @found_tables, $markdown =~ m{
            ^\+(?:-+\+)+\n
            (
                (?:
                    ^\|[^\n]+\n
                    (?:^(?:\+(?:-+\+)+)\n)?
                )+
            )
            ^(?:\+(?:-+\+)+)
        }g;
    }


    my @tables;

    for my $table ( @found_tables ) {
        my @lines = grep{ $_ =~ m{\A\|[^-]+} } split /\n/, $table;
     
        my $headerline = shift @lines;
        $headerline    =~ s{\A\|}{};
        $headerline    =~ s{\|$}{};
        my @cols       = split /\s+\|\s+/, $headerline;

        my @rows = map{
            $_ =~ s{\A\|}{};
            $_ =~ s{\|$}{};
            [ split /\s+\|\s+/, $_ ];
        } @lines;

        push @tables, $class->new(
            cols => \@cols,
            rows => \@rows,
        );
    }

    return @tables;
}

sub set_cols {
    my ($self, @cols) = @_;

    $self->_set_cols( \@cols );
    return $self->cols;
}

sub add_rows {
    my ($self, @new_rows) = @_;

    my $rows = $self->rows || [];
    push @{ $rows }, @new_rows; 
    $self->_set_rows( $rows );

    return $rows;
}

sub get_table {
    my ($self) = @_;

    my $ascii = Text::ASCIITable->new({
        hide_LastLine => 1,
        hide_FirstLine => 1,
    });

    $ascii->setCols( $self->cols );
    for my $row ( @{ $self->rows || [] } ) {
        $ascii->addRow( @{ $row } );
    }

    return $ascii->draw( undef, undef, [qw/| | - |/] );
}


1;

=head1 SYNOPSIS

To generate a table

    use Markdown::Table;

    my $table   = Markdown::Table->new;
    my @columns = qw(Id Name Role);
    $table->set_cols( @columns );

    my @data = (
        [ 1, 'John Smith', 'Testrole' ],
        [ 2, 'Jane Smith', 'Admin' ],
    );

    $table->add_rows( @data );

    print $table->get_table;

To get tables from an existing Markdown document

    use Markdown::Table;

    my $markdown = q~
This table shows all employees and their role.

| Id | Name | Role |
+---+---+---+
| 1 | John Smith | Testrole |
| 2 | Jane Smith | Admin |
~;

    my @tables = Markdown::Table->parse(
        $markdown,
    );

    print $tables[0]->get_table;

=head1 METHODS

=head2 new

=head2 set_cols

=head2 add_rows

=head2 get_table

=head2 parse

Parses the Markdown document and creates a L<Markdown::Table> object for each

=head1 SEE ALSO

If you just want to generate tables for Markdown documents, you can
use L<Text::ASCIITable>. This is the module, L<Markdown::Table> uses
for table generation, too.
